//
//  LocalizationSystem.h
//  Battle of Puppets
//
//  Created by Juan Albero Sanchis on 27/02/10.
//  Copyright Aggressive Mediocrity 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AMLocalizedString(key, comment) \
[[LocalizationSystem instance] localizedStringForKey:(key) value:(comment)]

#define LocalizationSetLanguage(language) \
[[LocalizationSystem instance] setLanguage:(language)]

#define LocalizationGetLanguage \
[[LocalizationSystem instance] getLanguage]

#define LocalizationReset \
[[LocalizationSystem instance] resetLocalization]

@interface LocalizationSystem : NSObject {
	NSString *language;
}

// you really shouldn't care about this functions and use the MACROS
+ (LocalizationSystem *) instance;

//gets the string localized
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;

//sets the language
- (void) setLanguage:(NSString*) language;

//gets the current language
- (NSString*) getLanguage;

//resets this system.
- (void) resetLocalization;

@end
