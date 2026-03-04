APP_NAME=DoubleCmdTranslator
APP_BUNDLE=$(APP_NAME).app
MACOS_VERSION_MIN=13.0

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@swiftc \
		-parse-as-library \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		-framework Cocoa -framework SwiftUI -framework Combine \
		Sources/DoubleCmdTranslatorLib/**/*.swift Sources/DoubleCmdTranslatorApp/main.swift
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>CFBundleExecutable</key>\n\t<string>$(APP_NAME)</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>com.gemini.$(APP_NAME)</string>\n\t<key>CFBundlePackageType</key>\n\t<string>APPL</string>\n\t<key>LSUIElement</key>\n\t<string>YES</string>\n</dict>\n</plist>' > $(APP_BUNDLE)/Contents/Info.plist
	@echo "Build complete."

run: build
	@echo "Running $(APP_NAME)..."
	@./$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)

test:
	@echo "Compiling tests..."
	@swiftc \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o test_runner \
		-framework Cocoa -framework Combine \
		Sources/DoubleCmdTranslatorLib/**/*.swift \
		Tests/TestFramework.swift Tests/AllTests.swift Tests/TestRunner.swift
	@echo "Running tests..."
	@./test_runner
	@rm -f test_runner

clean:
	@rm -rf $(APP_BUNDLE) .build
	@echo "Cleaned up."

