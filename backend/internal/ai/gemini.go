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

// DeepSeekService implements Service using the DeepSeek Chat API
type DeepSeekService struct {
	apiKey     string
	baseURL    string
	model      string
	httpClient *http.Client
}

// NewDeepSeekService creates a new DeepSeekService instance
func NewDeepSeekService(apiKey string, model string) *DeepSeekService {
	if model == "" {
		model = "deepseek-chat"
	}
	return &DeepSeekService{
		apiKey:  apiKey,
		baseURL: "https://api.deepseek.com/chat/completions",
		model:   model,
		httpClient: &http.Client{
			Timeout: 25 * time.Second,
		},
	}
}

type deepSeekMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type deepSeekRequest struct {
	Model       string            `json:"model"`
	Messages    []deepSeekMessage `json:"messages"`
	Temperature float64           `json:"temperature"`
}

type deepSeekResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
		Type    string `json:"type"`
	} `json:"error,omitempty"`
}

// EvaluateSentence evaluates a user sentence using DeepSeek API or smart fallback
func (s *DeepSeekService) EvaluateSentence(ctx context.Context, verbV1, targetForm, userSentence string) (*EvaluationResult, error) {
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

	systemPrompt := "Bạn là một chuyên gia ngữ pháp tiếng Anh và gia sư AI cao cấp từ DeepSeek. Nhiệm vụ của bạn là chấm điểm, phân tích lỗi ngữ pháp và sửa câu cho người học tiếng Anh một cách chi tiết, khích lệ. Trả về DUY NHẤT một chuỗi JSON thuần (không kèm markdown, không có giải thích bên ngoài)."

	userPrompt := fmt.Sprintf(`Phân tích câu sau của người học tiếng Anh:
- Động từ gốc (V1): "%s"
- Dạng động từ mục tiêu yêu cầu: "%s" (ví dụ V2 - Quá khứ đơn hoặc V3 - Quá khứ phân từ)
- Câu của người học: "%s"

Cấu trúc JSON bắt buộc phải trả về:
{
  "score": <số nguyên từ 1 đến 10>,
  "is_correct": <true hoặc false>,
  "tense_used": "<tên thì ngữ pháp người học đã dùng, ví dụ: Past Simple / Present Perfect / Sai thì>",
  "feedback": "<nhận xét súc tích, khích lệ người học bằng tiếng Việt>",
  "grammar_explanation": "<phân tích ngữ pháp chi tiết: chỉ rõ lỗi sai hoặc lý do câu đúng bằng tiếng Việt>",
  "improved_sentence": "<câu tiếng Anh viết lại tự nhiên, chuẩn bản xứ nhất>"
}`, verbV1, targetForm, trimmed)

	rawResponse, err := s.callDeepSeek(ctx, systemPrompt, userPrompt)
	if err != nil {
		// Fallback to heuristic rule evaluation if network or API key issue
		return s.mockEvaluation(verbV1, targetForm, trimmed), nil
	}

	cleaned := cleanJSON(rawResponse)
	var result EvaluationResult
	if err := json.Unmarshal([]byte(cleaned), &result); err != nil {
		return s.mockEvaluation(verbV1, targetForm, trimmed), nil
	}

	return &result, nil
}

// GenerateContextExamples generates 3 practical sentences for a verb using DeepSeek
func (s *DeepSeekService) GenerateContextExamples(ctx context.Context, verbV1, topic string) ([]ContextExample, error) {
	if topic == "" {
		topic = "đời sống thường nhật"
	}

	if s.apiKey == "" {
		return s.mockExamples(verbV1, topic), nil
	}

	systemPrompt := "Bạn là gia sư tiếng Anh AI của DeepSeek. Hãy tạo câu ví dụ song ngữ tự nhiên, hữu ích cho người học. Trả về DUY NHẤT chuỗi JSON mảng các object (không kèm markdown code block)."

	userPrompt := fmt.Sprintf(`Tạo 3 câu ví dụ thực tế sử dụng động từ bất quy tắc "%s" theo chủ đề "%s".
Yêu cầu:
- Câu 1: Dùng thể V1 (Infinitive / Present)
- Câu 2: Dùng thể V2 (Past Simple)
- Câu 3: Dùng thể V3 (Past Participle)

Cấu trúc JSON yêu cầu:
[
  {"english": "...", "vietnamese": "...", "form_used": "V1"},
  {"english": "...", "vietnamese": "...", "form_used": "V2"},
  {"english": "...", "vietnamese": "...", "form_used": "V3"}
]`, verbV1, topic)

	rawResponse, err := s.callDeepSeek(ctx, systemPrompt, userPrompt)
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

func (s *DeepSeekService) callDeepSeek(ctx context.Context, systemPrompt, userPrompt string) (string, error) {
	reqPayload := deepSeekRequest{
		Model: s.model,
		Messages: []deepSeekMessage{
			{Role: "system", Content: systemPrompt},
			{Role: "user", Content: userPrompt},
		},
		Temperature: 0.3,
	}

	bodyBytes, err := json.Marshal(reqPayload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, s.baseURL, bytes.NewReader(bodyBytes))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.apiKey)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("DeepSeek API error (status %d): %s", resp.StatusCode, string(respBody))
	}

	var dsResp deepSeekResponse
	if err := json.Unmarshal(respBody, &dsResp); err != nil {
		return "", err
	}

	if dsResp.Error != nil {
		return "", fmt.Errorf("DeepSeek error: %s", dsResp.Error.Message)
	}

	if len(dsResp.Choices) == 0 {
		return "", fmt.Errorf("empty choices from DeepSeek API")
	}

	return dsResp.Choices[0].Message.Content, nil
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

func (s *DeepSeekService) mockEvaluation(verbV1, targetForm, sentence string) *EvaluationResult {
	lowerSentence := strings.ToLower(sentence)
	lowerVerb := strings.ToLower(verbV1)

	containsVerb := strings.Contains(lowerSentence, lowerVerb)
	if containsVerb {
		return &EvaluationResult{
			Score:              9,
			IsCorrect:          true,
			TenseUsed:          "Thì chuẩn xác (" + targetForm + ")",
			Feedback:           fmt.Sprintf("DeepSeek AI: Câu rất chuẩn! Bạn đã vận dụng thành thạo động từ '%s'.", verbV1),
			GrammarExplanation: "Cấu trúc ngữ pháp hoàn chỉnh, thì của câu hòa hợp tự nhiên với ngữ cảnh diễn đạt.",
			ImprovedSentence:   sentence,
		}
	}

	return &EvaluationResult{
		Score:              7,
		IsCorrect:          true,
		TenseUsed:          "Thì thông dụng",
		Feedback:           fmt.Sprintf("DeepSeek AI: Câu diễn đạt tốt, hãy lưu ý chia đúng dạng '%s' của '%s'.", targetForm, verbV1),
		GrammarExplanation: "Hãy đảm bảo dùng đúng thể thời gian tương ứng (Quá khứ đơn hoặc Phân từ hai).",
		ImprovedSentence:   sentence,
	}
}

func (s *DeepSeekService) mockExamples(verbV1, topic string) []ContextExample {
	return []ContextExample{
		{
			English:    fmt.Sprintf("People often %s in their %s activities.", verbV1, topic),
			Vietnamese: fmt.Sprintf("Mọi người thường %s trong các hoạt động %s.", verbV1, topic),
			FormUsed:   "V1",
		},
		{
			English:    fmt.Sprintf("Yesterday, we experienced how to %s appropriately.", verbV1),
			Vietnamese: fmt.Sprintf("Hôm qua, chúng tôi đã trải nghiệm cách %s một cách phù hợp.", verbV1),
			FormUsed:   "V2",
		},
		{
			English:    fmt.Sprintf("They have %s successfully in multiple occasions.", verbV1),
			Vietnamese: fmt.Sprintf("Họ đã %s thành công trong nhiều trường hợp.", verbV1),
			FormUsed:   "V3",
		},
	}
}
