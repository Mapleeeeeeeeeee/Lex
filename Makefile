APP_NAME=Lex
APP_BUNDLE=$(APP_NAME).app
MACOS_VERSION_MIN=13.0

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp -R Sources/LexLib/Resources/* $(APP_BUNDLE)/Contents/Resources/
	@cp Assets/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/ 2>/dev/null || true
	@swiftc \
		-parse-as-library \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		-framework Cocoa -framework SwiftUI -framework Combine \
		Sources/LexLib/**/*.swift Sources/LexApp/main.swift
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>CFBundleExecutable</key>\n\t<string>$(APP_NAME)</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>com.gemini.$(APP_NAME)</string>\n\t<key>CFBundlePackageType</key>\n\t<string>APPL</string>\n\t<key>LSUIElement</key>\n\t<string>YES</string>\n\t<key>CFBundleIconFile</key>\n\t<string>AppIcon</string>\n</dict>\n</plist>' > $(APP_BUNDLE)/Contents/Info.plist
	@echo "Build complete."

run: build
	@echo "Running $(APP_NAME)..."
	@./$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)

test:
	@echo "Compiling tests..."
	@mkdir -p Resources
	@cp -R Sources/LexLib/Resources/* Resources/
	@swiftc \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o test_runner \
		-framework Cocoa -framework Combine \
		Sources/LexLib/**/*.swift \
		Tests/*.swift
	@echo "Running tests..."
	@./test_runner
	@rm -f test_runner

clean:
	@rm -rf $(APP_BUNDLE) .build Lex.dmg Lex.app.zip
	@echo "Cleaned up."

zip: build
	@echo "Packaging ZIP..."
	@zip -r Lex.app.zip Lex.app

dmg: build
	@echo "Packaging DMG..."
	@mkdir -p build_dmg
	@cp -R Lex.app build_dmg/
	@ln -s /Applications build_dmg/Applications
	@hdiutil create -volname "$(APP_NAME)" -srcfolder build_dmg -ov -format UDZO $(APP_NAME).dmg
	@rm -rf build_dmg

release: zip dmg
	@echo "Release packages ready."
