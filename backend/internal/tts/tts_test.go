package tts

import (
	"os"
	"path/filepath"
	"testing"
)

func TestGenerateMP3(t *testing.T) {
	tmpFile := filepath.Join(os.TempDir(), "test_tts.mp3")
	defer os.Remove(tmpFile)

	err := GenerateMP3("speak", tmpFile)
	if err != nil {
		t.Fatalf("GenerateMP3 failed: %v", err)
	}

	info, err := os.Stat(tmpFile)
	if err != nil {
		t.Fatalf("failed to stat generated file: %v", err)
	}

	if info.Size() == 0 {
		t.Errorf("generated file size is 0")
	}
}

func TestGenerateMP3_EmptyText(t *testing.T) {
	tmpFile := filepath.Join(os.TempDir(), "empty_tts.mp3")
	err := GenerateMP3("   ", tmpFile)
	if err == nil {
		t.Errorf("expected error on empty text")
	}
}
