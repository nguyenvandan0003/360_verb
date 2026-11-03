package srs

import (
	"testing"
	"time"
)

func TestCalculateSM2_InitialGrade5(t *testing.T) {
	now := time.Date(2026, 11, 3, 12, 0, 0, 0, time.UTC)
	res := CalculateSM2(0, 0, 2.5, 5, now)

	if res.Repetitions != 1 {
		t.Errorf("expected Repetitions 1, got %d", res.Repetitions)
	}
	if res.IntervalDays != 1 {
		t.Errorf("expected IntervalDays 1, got %d", res.IntervalDays)
	}
	if res.EasinessFactor != 2.6 { // 2.5 + (0.1 - 0) = 2.6
		t.Errorf("expected EF 2.6, got %f", res.EasinessFactor)
	}
	expectedDate := now.AddDate(0, 0, 1)
	if !res.NextReviewAt.Equal(expectedDate) {
		t.Errorf("expected NextReviewAt %v, got %v", expectedDate, res.NextReviewAt)
	}
}

func TestCalculateSM2_SecondGrade4(t *testing.T) {
	now := time.Date(2026, 11, 3, 12, 0, 0, 0, time.UTC)
	res := CalculateSM2(1, 1, 2.6, 4, now)

	if res.Repetitions != 2 {
		t.Errorf("expected Repetitions 2, got %d", res.Repetitions)
	}
	if res.IntervalDays != 6 {
		t.Errorf("expected IntervalDays 6, got %d", res.IntervalDays)
	}
	// diff = 1 => 0.1 - 1*(0.08+0.02) = 0.0 => EF = 2.6
	if res.EasinessFactor != 2.6 {
		t.Errorf("expected EF 2.6, got %f", res.EasinessFactor)
	}
}

func TestCalculateSM2_FailureGrade2(t *testing.T) {
	now := time.Date(2026, 11, 3, 12, 0, 0, 0, time.UTC)
	res := CalculateSM2(3, 15, 2.5, 2, now)

	if res.Repetitions != 0 {
		t.Errorf("expected reset Repetitions 0, got %d", res.Repetitions)
	}
	if res.IntervalDays != 1 {
		t.Errorf("expected reset IntervalDays 1, got %d", res.IntervalDays)
	}
	if res.EasinessFactor >= 2.5 {
		t.Errorf("expected EF to decrease, got %f", res.EasinessFactor)
	}
}

func TestCalculateSM2_MinimumEasinessFactor(t *testing.T) {
	now := time.Now()
	res := CalculateSM2(0, 0, 1.3, 0, now)
	if res.EasinessFactor < 1.3 {
		t.Errorf("EF should not drop below 1.3, got %f", res.EasinessFactor)
	}
}
