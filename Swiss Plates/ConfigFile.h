//
//  ConfigFile.h
//  Swiss Plates
//
//  Created by Alain Furter on 22.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#ifndef Swiss_Plates_ConfigFile_h
#define Swiss_Plates_ConfigFile_h

//Test code on / off
#define AdsCodeIsOn 1

// Verify receipt code: 1 = sandbox; 0 = appstore live
//#define kVERIFYRECEIPTISSANDBOX 1

// Server configuration
#define AppID   @"2"
#define AppVersion @"2.0"

//App id for Swiss Plates FREE auf MySQL DB on APNS Server with hoststar
#define DeviceAlreadyRegisteredForRemoteNotificationFlagfile @"rnff.plist"  //Flagfile if device already registered on server

//Status notice file
#define kStatusNoticefile @"statusnotices.plist"

//Unlock voucher code file
#define kUnlockVoucherFieldFile @"voucher.plist"

// Recommendation settings
#define kITellAFriendImageURLBig    @"http://www.zonezeroapps.com/swissplates/icons/itellafriendiconB.png"
#define kITellAFriendImageURLMedium @"http://www.zonezeroapps.com/swissplates/icons/itellafriendiconM.png"
#define kITellAFriendImageURLSmall  @"http://www.zonezeroapps.com/swissplates/icons/itellafriendiconS.png"

#define kAppCategory                @"Reference"
#define kAppName                    @"Swiss Plates"
#define kAppSeller                  @"Alain Furter"
#define kAppStoreCountry            @"CH"
#define kBundleIconImage            @"TwitterImage.png"

#define kUTControllerAppName        @"SPFREE2.0"

// Twitter settings
#define kTwitterUsername            @"swissplates"

// Facebook settings
#define kFacebookAppID              @"351494151590743"

// Support
#define kSupportEmail               @"support@zonezeroapps.com"

//#define kForceIntroRun              1

//#define NONETWORK 1

// Logging via NSLog
//#define kLoggingIsOn                      1
//#define AddDecodingErrorResponseToEmail   1

//Store config defines
#define kOFFSET_FOR_KEYBOARD 180

//Appstore settings
#define AppStoreID                  528668110       // SWISS PLATES FREE
#define AppStoreURLShort            @"http://bit.ly/17mMyXt"

//Non web view controller push pop settings
#define kUseCustomTabbarControllerForPushAndPop 1

//CantonsViewController settings
#define kCheckForiPodServiceRestrictions        1
//#define kSimulateiPodTouchPresence              1

enum DIRECTION {
    NONE,
    RIGHT,
    LEFT,
    UP,
    DOWN,
    CRAZY,
};

#define TOOLBARHEIGHT 44.0
#define WAITVIEWHEIGHT 95.0
#define EXPVIEWHEIGHT 265.0
#define EXPVIEWR4ADJ 38.0
#define INTROADJ 40.0
#define EMPTYADJ 5.0

#endif
