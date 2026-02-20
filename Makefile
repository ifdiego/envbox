BINDIR := $(HOME)/.local/bin
TARGET := $(BINDIR)/vidcompress
SOURCE := compress_video.sh

.PHONY: all install uninstall

all: uninstall install

install:
	@mkdir -p "$(BINDIR)"
	@cp "$(SOURCE)" "$(TARGET)"
	@chmod +x "$(TARGET)"
	@echo "vidcompress is ready to use"

uninstall:
	@rm -f "$(TARGET)"
	@echo "vidcompress has been removed"
