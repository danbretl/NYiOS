//
//  PushHelper.h
//  Emotish
//
//  Created by Dan Bretl on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

extern NSString * const PUSH_USER_CHANNEL_PREFIX; // Necessary because all channels must start with a letter
extern NSString * const PUSH_APP_CHANNEL_PREFIX; // Necessary because all channels must start with a letter
extern NSString * const PUSH_RELATION;

@interface PushHelper : NSObject

+ (void)updatePushNotificationSubscriptionsForMember:(PFUser *)member;

+ (void) sendPushNotificationFromMember:(PFUser *)memberSource forListingOfApp:(PFObject *)app claimedRelation:(NSString *)relation;

@end
