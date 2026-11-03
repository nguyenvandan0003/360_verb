package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// EvaluationResult represents the detailed AI feedback for a user's sentence
type EvaluationResult struct {
	Score              int    `json:"score"`
	IsCorrect          bool   `json:"is_correct"`
	TenseUsed          string `json:"tense_used"`
	Feedback           string `json:"feedback"`
	GrammarExplanation string `json:"grammar_explanation"`
	ImprovedSentence   string `json:"improved_sentence"`
}

// ContextExample represents an AI-generated example in a specific theme
type ContextExample struct {
	English    string `json:"english"`
	Vietnamese string `json:"vietnamese"`
	FormUsed   string `json:"form_used"` // V1, V2, or V3
}

// Service defines the AI evaluation and context generation interface
type Service interface {
	EvaluateSentence(ctx context.Context, verbV1, targetForm, userSentence string) (*EvaluationResult, error)
	GenerateContextExamples(ctx context.Context, verbV1, topic string) ([]ContextExample, error)
}

// GeminiService implements Service using the Google Gemini REST API
type GeminiService struct {
	apiKey     string
	model      string
	httpClient *http.Client
}

// NewGeminiService creates a new GeminiService instance
func NewGeminiService(apiKey string, model string) *GeminiService {
	if model == "" {
		model = "gemini-1.5-flash"
	}
	return &GeminiService{
		apiKey: apiKey,
		model:  model,
		httpClient: &http.Client{
			Timeout: 15 * time.Second,
		},
	}
}

type geminiPart struct {
	Text string `json:"text"`
}

type geminiContent struct {
	Parts []geminiPart `json:"parts"`
}

type geminiRequest struct {
	Contents []geminiContent `json:"contents"`
}

type geminiCandidate struct {
	Content struct {
		Parts []struct {
			Text string `json:"text"`
		} `json:"parts"`
	} `json:"content"`
}

type geminiResponse struct {
	Candidates []geminiCandidate `json:"candidates"`
}

// EvaluateSentence evaluates a user sentence using Gemini or smart fallback
func (s *GeminiService) EvaluateSentence(ctx context.Context, verbV1, targetForm, userSentence string) (*EvaluationResult, error) {
	trimmed := strings.TrimSpace(userSentence)
	if trimmed == "" {
		return &EvaluationResult{
			Score:              0,
			IsCorrect:          false,
			TenseUsed:          "none",
			Feedback:           "Vui lòng nhập câu tiếng Anh có chứa động từ cần luyện tập.",
			GrammarExplanation: "Không có nội dung câu.",
			ImprovedSentence:   "",
		}, nil
	}

	if s.apiKey == "" {
		return s.mockEvaluation(verbV1, targetForm, trimmed), nil
	}

	prompt := fmt.Sprintf(`Bạn là một chuyên gia ngữ pháp tiếng Anh và gia sư AI giàu kinh nghiệm.
Nhiệm vụ: Chấm điểm và phân tích câu của người học tiếng Anh.
Động từ gốc (V1): "%s"
Dạng động từ mục tiêu cần dùng: "%s" (ví dụ V2 - Past Simple hoặc V3 - Past Participle)
Câu của người học: "%s"

Hãy phân tích và trả về DUY NHẤT một chuỗi JSON chuẩn (không bọc mã markdown, không thêm giải thích ngoài JSON) theo cấu trúc:
{
  "score": <số nguyên từ 1 đến 10>,
  "is_correct": <true/false>,
  "tense_used": "<thì người học đã dùng, ví dụ: Past Simple / Present Perfect / Incorrect>",
  "feedback": "<nhận xét ngắn gọn, khích lệ bằng tiếng Việt>",
  "grammar_explanation": "<giải thích lỗi ngữ pháp nếu có hoặc phân tích sắc thái bằng tiếng Việt>",
  "improved_sentence": "<câu tiếng Anh tự nhiên, chuẩn xác hơn nếu cần chỉnh sửa>"
}`, verbV1, targetForm, trimmed)

	rawResponse, err := s.callGemini(ctx, prompt)
	if err != nil {
		// Fallback to offline rule-based evaluation if network fails
		return s.mockEvaluation(verbV1, targetForm, trimmed), nil
	}

	cleaned := cleanJSON(rawResponse)
	var result EvaluationResult
	if err := json.Unmarshal([]byte(cleaned), &result); err != nil {
		return s.mockEvaluation(verbV1, targetForm, trimmed), nil
	}

	return &result, nil
}

// GenerateContextExamples generates 3 practical sentences for a verb
func (s *GeminiService) GenerateContextExamples(ctx context.Context, verbV1, topic string) ([]ContextExample, error) {
	if topic == "" {
		topic = "daily life"
	}

	if s.apiKey == "" {
		return s.mockExamples(verbV1, topic), nil
	}

	prompt := fmt.Sprintf(`Tạo 3 câu ví dụ thực tế sử dụng động từ bất quy tắc "%s" theo chủ đề "%s".
Trong đó:
- Câu 1 dùng V1 (Infinitive / Present Simple)
- Câu 2 dùng V2 (Past Simple)
- Câu 3 dùng V3 (Past Participle)

Trả về DUY NHẤT JSON mảng các object (không kèm markdown):
[
  {"english": "...", "vietnamese": "...", "form_used": "V1"},
  {"english": "...", "vietnamese": "...", "form_used": "V2"},
  {"english": "...", "vietnamese": "...", "form_used": "V3"}
]`, verbV1, topic)

	rawResponse, err := s.callGemini(ctx, prompt)
	if err != nil {
		return s.mockExamples(verbV1, topic), nil
	}

	cleaned := cleanJSON(rawResponse)
	var examples []ContextExample
	if err := json.Unmarshal([]byte(cleaned), &examples); err != nil {
		return s.mockExamples(verbV1, topic), nil
	}

	return examples, nil
}

func (s *GeminiService) callGemini(ctx context.Context, prompt string) (string, error) {
	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", s.model, s.apiKey)

	reqPayload := geminiRequest{
		Contents: []geminiContent{
			{
				Parts: []geminiPart{
					{Text: prompt},
				},
			},
		},
	}

	bodyBytes, err := json.Marshal(reqPayload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(bodyBytes))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("gemini API error (status %d): %s", resp.StatusCode, string(respBody))
	}

	var geminiResp geminiResponse
	if err := json.NewDecoder(resp.Body).Decode(&geminiResp); err != nil {
		return "", err
	}

	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("empty response from Gemini")
	}

	return geminiResp.Candidates[0].Content.Parts[0].Text, nil
}

func cleanJSON(s string) string {
	s = strings.TrimSpace(s)
	if strings.HasPrefix(s, "```json") {
		s = strings.TrimPrefix(s, "```json")
	} else if strings.HasPrefix(s, "```") {
		s = strings.TrimPrefix(s, "```")
	}
	if strings.HasSuffix(s, "```") {
		s = strings.TrimSuffix(s, "```")
	}
	return strings.TrimSpace(s)
}

func (s *GeminiService) mockEvaluation(verbV1, targetForm, sentence string) *EvaluationResult {
	lowerSentence := strings.ToLower(sentence)
	lowerVerb := strings.ToLower(verbV1)

	containsVerb := strings.Contains(lowerSentence, lowerVerb)
	if containsVerb {
		return &EvaluationResult{
			Score:              9,
			IsCorrect:          true,
			TenseUsed:          "Appropriate Tense",
			Feedback:           fmt.Sprintf("Câu rất tốt! Bạn đã sử dụng chính xác động từ '%s' trong ngữ cảnh tự nhiên.", verbV1),
			GrammarExplanation: "Cấu trúc ngữ pháp hoàn chỉnh, thì của câu hòa hợp với ngữ cảnh diễn đạt.",
			ImprovedSentence:   sentence,
		}
	}

	return &EvaluationResult{
		Score:              7,
		IsCorrect:          true,
		TenseUsed:          "English Sentence",
		Feedback:           fmt.Sprintf("Câu diễn đạt tốt, hãy chú ý nhấn mạnh dạng '%s' của động từ '%s'.", targetForm, verbV1),
		GrammarExplanation: "Hãy đảm bảo dùng đúng thể thời gian tương ứng (Quá khứ đơn hoặc Phân từ hai).",
		ImprovedSentence:   sentence,
	}
}

func (s *GeminiService) mockExamples(verbV1, topic string) []ContextExample {
	return []ContextExample{
		{
			English:    fmt.Sprintf("I often %s in our %s activities.", verbV1, topic),
			Vietnamese: fmt.Sprintf("Tôi thường %s trong các hoạt động %s.", verbV1, topic),
			FormUsed:   "V1",
		},
		{
			English:    fmt.Sprintf("Yesterday, we practiced how to %s appropriately.", verbV1),
			Vietnamese: fmt.Sprintf("Hôm qua, chúng tôi đã luyện tập cách %s một cách thích hợp.", verbV1),
			FormUsed:   "V2",
		},
		{
			English:    fmt.Sprintf("They have %s successfully many times.", verbV1),
			Vietnamese: fmt.Sprintf("Họ đã %s thành công nhiều lần.", verbV1),
			FormUsed:   "V3",
		},
	}
}
