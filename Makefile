include theos/makefiles/common.mk

TWEAK_NAME = FacebookFolder
FacebookFolder_FILES = Tweak.xm UIImage+Resize.m UIImage+Alpha.m UIImage+Editor.m
FacebookFolder_FRAMEWORKS = UIKit CoreGraphics Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
