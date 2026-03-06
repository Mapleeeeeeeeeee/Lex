APP_NAME=Lex
APP_BUNDLE=$(APP_NAME).app
MACOS_VERSION_MIN=13.0

VERSION=$(shell ./get_version.sh)

build: icon
	@echo "Building $(APP_NAME) v$(VERSION)..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp -R Sources/LexLib/Resources/* $(APP_BUNDLE)/Contents/Resources/
	@cp Assets/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/ 2>/dev/null || true
	@mkdir -p $(APP_BUNDLE)/Contents/Frameworks
	@cp -R Frameworks/Sparkle.framework $(APP_BUNDLE)/Contents/Frameworks/
	@swiftc \
		-parse-as-library \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		-F Frameworks -framework Cocoa -framework SwiftUI -framework Combine -framework Sparkle \
		Sources/LexLib/**/*.swift Sources/LexApp/main.swift
	@install_name_tool -add_rpath @executable_path/../Frameworks $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>CFBundleDevelopmentRegion</key>\n\t<string>zh_TW</string>\n\t<key>CFBundleLocalizations</key>\n\t<array>\n\t\t<string>zh_TW</string>\n\t</array>\n\t<key>CFBundleExecutable</key>\n\t<string>$(APP_NAME)</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>com.gemini.$(APP_NAME)</string>\n\t<key>CFBundlePackageType</key>\n\t<string>APPL</string>\n\t<key>LSUIElement</key>\n\t<string>YES</string>\n\t<key>CFBundleIconFile</key>\n\t<string>AppIcon</string>\n\t<key>CFBundleShortVersionString</key>\n\t<string>$(VERSION)</string>\n\t<key>CFBundleVersion</key>\n\t<string>$(VERSION)</string>\n\t<key>SUFeedURL</key>\n\t<string>https://mapleeeeeeeeeee.github.io/Lex/appcast.xml</string>\n\t<key>SUPublicEDKey</key>\n\t<string>PfCyMfARoazOM+1dL7i7WcLtY+ba2Vp5QUouj+p5F3E=</string>\n</dict>\n</plist>' > $(APP_BUNDLE)/Contents/Info.plist
	@codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "Build complete."

icon:
	@echo "Generating app icon..."
	@mkdir -p Assets/AppIcon.iconset
	@sips -z 16 16     Assets/icon.png --out Assets/AppIcon.iconset/icon_16x16.png > /dev/null
	@sips -z 32 32     Assets/icon.png --out Assets/AppIcon.iconset/icon_16x16@2x.png > /dev/null
	@sips -z 32 32     Assets/icon.png --out Assets/AppIcon.iconset/icon_32x32.png > /dev/null
	@sips -z 64 64     Assets/icon.png --out Assets/AppIcon.iconset/icon_32x32@2x.png > /dev/null
	@sips -z 128 128   Assets/icon.png --out Assets/AppIcon.iconset/icon_128x128.png > /dev/null
	@sips -z 256 256   Assets/icon.png --out Assets/AppIcon.iconset/icon_128x128@2x.png > /dev/null
	@sips -z 256 256   Assets/icon.png --out Assets/AppIcon.iconset/icon_256x256.png > /dev/null
	@sips -z 512 512   Assets/icon.png --out Assets/AppIcon.iconset/icon_256x256@2x.png > /dev/null
	@sips -z 512 512   Assets/icon.png --out Assets/AppIcon.iconset/icon_512x512.png > /dev/null
	@sips -z 1024 1024 Assets/icon.png --out Assets/AppIcon.iconset/icon_512x512@2x.png > /dev/null
	@iconutil -c icns Assets/AppIcon.iconset
	@rm -rf Assets/AppIcon.iconset

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
		-F Frameworks -framework Cocoa -framework Combine -framework Sparkle \
		Sources/LexLib/**/*.swift \
		Tests/*.swift
	@install_name_tool -add_rpath @executable_path/Frameworks test_runner
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

appcast:
	@echo "Generating appcast..."
	@mkdir -p appcast_build
	@cp Lex.dmg appcast_build/
	@./Frameworks/bin/generate_appcast appcast_build/
	@mkdir -p docs
	@cp appcast_build/appcast.xml docs/
	@sed -i '' 's|https://mapleeeeeeeeeee.github.io/Lex/Lex.dmg|https://github.com/Mapleeeeeeeeeee/Lex/releases/download/v$(VERSION)/Lex.dmg|g' docs/appcast.xml
	@rm -rf appcast_build
