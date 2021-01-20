export SDKVERSION=11.2

DEBUG = 0
FINALPACKAGE = 1
export COPYFILE_DISABLE = 1

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += Tweak Prefs

include $(THEOS_MAKE_PATH)/aggregate.mk
