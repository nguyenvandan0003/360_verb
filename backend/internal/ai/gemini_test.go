package ai

import (
	"context"
	"testing"
)

func TestDeepSeekService_MockEvaluation(t *testing.T) {
	service := NewDeepSeekService("", "")

	ctx := context.Background()
	res, err := service.EvaluateSentence(ctx, "go", "V2", "I went to school yesterday.")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if res.Score < 1 || res.Score > 10 {
		t.Errorf("expected score between 1 and 10, got %d", res.Score)
	}
	if res.Feedback == "" {
		t.Errorf("feedback should not be empty")
	}
}

func TestDeepSeekService_EmptySentence(t *testing.T) {
	service := NewDeepSeekService("", "")

	ctx := context.Background()
	res, err := service.EvaluateSentence(ctx, "take", "V2", "   ")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if res.Score != 0 || res.IsCorrect {
		t.Errorf("expected empty sentence to get 0 score and isCorrect=false")
	}
}

func TestDeepSeekService_GenerateExamples(t *testing.T) {
	service := NewDeepSeekService("", "")

	ctx := context.Background()
	examples, err := service.GenerateContextExamples(ctx, "break", "work")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if len(examples) != 3 {
		t.Errorf("expected 3 examples, got %d", len(examples))
	}
	if examples[0].FormUsed != "V1" {
		t.Errorf("expected first example to be V1, got %s", examples[0].FormUsed)
	}
}
