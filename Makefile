APP_NAME=Lex
APP_BUNDLE=$(APP_NAME).app
MACOS_VERSION_MIN=13.0
SIGN_IDENTITY ?= -

VERSION=$(shell ./get_version.sh)

build:
	@echo "Building $(APP_NAME) v$(VERSION)..."
	@[ -f Assets/AppIcon.icns ] || { echo "Missing Assets/AppIcon.icns."; exit 1; }
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources/zh_TW.lproj
	@cp -R Sources/LexLib/Resources/* $(APP_BUNDLE)/Contents/Resources/
	@cp Assets/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/ 2>/dev/null || true
	@mkdir -p $(APP_BUNDLE)/Contents/Frameworks
	@cp -a Frameworks/Sparkle.framework $(APP_BUNDLE)/Contents/Frameworks/
	@swiftc \
		-parse-as-library \
		-target $(shell uname -m)-apple-macosx$(MACOS_VERSION_MIN) \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		-F Frameworks -framework Cocoa -framework SwiftUI -framework Combine -framework Sparkle \
		Sources/LexLib/**/*.swift Sources/LexApp/main.swift
	@install_name_tool -add_rpath @executable_path/../Frameworks $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>CFBundleDevelopmentRegion</key>\n\t<string>zh_TW</string>\n\t<key>CFBundleLocalizations</key>\n\t<array>\n\t\t<string>zh_TW</string>\n\t</array>\n\t<key>CFBundleExecutable</key>\n\t<string>$(APP_NAME)</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>com.gemini.$(APP_NAME)</string>\n\t<key>CFBundlePackageType</key>\n\t<string>APPL</string>\n\t<key>LSUIElement</key>\n\t<string>YES</string>\n\t<key>CFBundleIconFile</key>\n\t<string>AppIcon</string>\n\t<key>CFBundleShortVersionString</key>\n\t<string>$(VERSION)</string>\n\t<key>CFBundleVersion</key>\n\t<string>$(VERSION)</string>\n\t<key>SUFeedURL</key>\n\t<string>https://mapleeeeeeeeeee.github.io/Lex/appcast.xml</string>\n\t<key>SUPublicEDKey</key>\n\t<string>PfCyMfARoazOM+1dL7i7WcLtY+ba2Vp5QUouj+p5F3E=</string>\n</dict>\n</plist>' > $(APP_BUNDLE)/Contents/Info.plist
	@./Scripts/sparkle_bundle.sh sign $(APP_BUNDLE) "$(SIGN_IDENTITY)"
	@./Scripts/sparkle_bundle.sh verify $(APP_BUNDLE)
	@echo "Build complete."

icon:
	@echo "Syncing README icon preview from AppIcon.icns..."
	@[ -f Assets/AppIcon.icns ] || { echo "Missing Assets/AppIcon.icns."; exit 1; }
	@rm -rf Assets/AppIcon.iconset
	@iconutil --convert iconset --output Assets/AppIcon.iconset Assets/AppIcon.icns
	@cp Assets/AppIcon.iconset/icon_512x512@2x.png Assets/icon.png
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

verify-sparkle:
	@./Scripts/sparkle_bundle.sh verify $(APP_BUNDLE)

clean:
	@rm -rf $(APP_BUNDLE) .build Lex.dmg Lex.app.zip
	@echo "Cleaned up."

zip: build
	@echo "Packaging ZIP..."
	@zip -r Lex.app.zip Lex.app

dmg: build
	@echo "Packaging DMG..."
	@mkdir -p build_dmg
	@cp -a Lex.app build_dmg/
	@ln -s /Applications build_dmg/Applications
	@hdiutil create -volname "$(APP_NAME)" -srcfolder build_dmg -ov -format UDZO $(APP_NAME).dmg
	@rm -rf build_dmg

release: zip dmg
	@echo "Release packages ready."

appcast:
	@echo "Generating appcast..."
	@mkdir -p appcast_build
	@cp Lex.dmg appcast_build/
	@if [ -n "$$SPARKLE_PRIVATE_KEY" ]; then \
		echo "$$SPARKLE_PRIVATE_KEY" | ./Frameworks/bin/generate_appcast appcast_build/ --ed-key-file -; \
	else \
		./Frameworks/bin/generate_appcast appcast_build/; \
	fi
	@mkdir -p docs
	@cp appcast_build/appcast.xml docs/
	@sed -i '' 's|https://mapleeeeeeeeeee.github.io/Lex/Lex.dmg|https://github.com/Mapleeeeeeeeeee/Lex/releases/download/v$(VERSION)/Lex.dmg|g' docs/appcast.xml
	@rm -rf appcast_build
