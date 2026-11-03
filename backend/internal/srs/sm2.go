package srs

import (
	"math"
	"time"
)

// SM2Result holds the recalculated spaced repetition state
type SM2Result struct {
	Repetitions    int       `json:"repetitions"`
	IntervalDays   int       `json:"interval_days"`
	EasinessFactor float64   `json:"easiness_factor"`
	NextReviewAt   time.Time `json:"next_review_at"`
}

// CalculateSM2 computes the next interval and easiness factor based on the SuperMemo-2 algorithm.
// grade:
// 0 - Complete blackout
// 1 - Incorrect response; the correct one remembered
// 2 - Incorrect response; where the correct one seemed easy to recall
// 3 - Correct response recalled with serious difficulty (Again / Hard)
// 4 - Correct response after a hesitation (Good)
// 5 - Perfect response (Easy)
func CalculateSM2(repetitions int, intervalDays int, easinessFactor float64, grade int, now time.Time) SM2Result {
	if easinessFactor < 1.3 {
		easinessFactor = 1.3
	}

	var newReps int
	var newInterval int

	if grade >= 3 {
		// Correct response
		if repetitions == 0 {
			newInterval = 1
		} else if repetitions == 1 {
			newInterval = 6
		} else {
			newInterval = int(math.Round(float64(intervalDays) * easinessFactor))
		}
		newReps = repetitions + 1
	} else {
		// Incorrect response: reset repetitions
		newReps = 0
		newInterval = 1
	}

	// Update Easiness Factor: EF' = EF + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02))
	diff := float64(5 - grade)
	newEF := easinessFactor + (0.1 - diff*(0.08+diff*0.02))
	if newEF < 1.3 {
		newEF = 1.3
	}

	// Round EF to 2 decimal places
	newEF = math.Round(newEF*100) / 100

	nextReview := now.AddDate(0, 0, newInterval)

	return SM2Result{
		Repetitions:    newReps,
		IntervalDays:   newInterval,
		EasinessFactor: newEF,
		NextReviewAt:   nextReview,
	}
}
