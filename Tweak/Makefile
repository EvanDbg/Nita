ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nita
Nita_FILES = Tweak.x
Nita_CFLAGS = -fobjc-arc -Wno-unguarded-availability-new
Nita_FRAMEWORKS = UIKit CoreLocation
Nita_EXTRA_FRAMEWORKS = Cephei
Nita_PRIVATE_FRAMEWORKS = SpringBoardFoundation Weather WeatherUI

include $(THEOS_MAKE_PATH)/tweak.mk
