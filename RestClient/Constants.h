//
//  Constants.h
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#ifndef RestClient_Cosntants_h
#define RestClient_Cosntants_h

#define kDefaultTimeout 10
#define kTimeoutMaxValue 180
#define kTimeoutMinValue 2
#define kTimeoutIncrementValue 1
#define kDefaultCancelOnFailure YES

// File Names

#define kRestClientDataFile @"RestClientData.data"

// Notifications

#define HistoryDidUpdateNotification @"HistoryDidUpdateNotification"

// Helper Macro Functions

#define NSStringFromBOOL(value) value ? @"YES" : @"NO"

#define AMKeyLocalizedString(string) NSLocalizedString(string, string)

#define rgb(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define rgba(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || thing == [NSNull null]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

#endif
