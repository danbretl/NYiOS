//
//  PushHelper.m
//  Emotish
//
//  Created by Dan Bretl on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushHelper.h"
#import "ParseClient.h"

NSString * const PUSH_USER_CHANNEL_PREFIX = @"u"; // Necessary because all channels must start with a letter
NSString * const PUSH_APP_CHANNEL_PREFIX = @"a"; // Necessary because all channels must start with a letter
NSString * const PUSH_RELATION = @"p_rel";

@implementation PushHelper

+ (void)updatePushNotificationSubscriptionsForMember:(PFUser *)member {
    
    NSLog(@"Updating push notification subscriptions, given current user (id=%@)", member.objectId);
    
    NSMutableArray * appListingsForAppSubscription = [NSMutableArray array];
    
    void(^updateBlock)(void) = ^{
        // Check what channels we are currently subscribed to. Make sure we are only subscribed to the empty "" channel, and the user-specific channel (if a user is currently logged in).
        [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet * channels, NSError * error) {
            if (!error) {
                BOOL subscribedToGeneral = NO;
                BOOL subscribedToUser = member == nil;
                for (NSString * channelName in channels) {
                    NSLog(@"  Analyzing existing subscription to channel \"%@\"", channelName);
                    if (!subscribedToGeneral && [channelName isEqualToString:@""]) {
                        NSLog(@"    Already subscribed to general push channel \"\"");
                        subscribedToGeneral = YES;
                    } else if (!subscribedToUser && [channelName isEqualToString:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, member.objectId]]) {
                        NSLog(@"    Already subscribed to user push channel \"%@\"", channelName);
                        subscribedToUser = YES;
                    } else {
                        BOOL appSubscribe = NO;
                        if (member != nil) {
                            for (PFObject * appListing in appListingsForAppSubscription) {
                                PFObject * app = [appListing objectForKey:@"app"];
                                if ([channelName isEqualToString:[NSString stringWithFormat:@"%@%@", PUSH_APP_CHANNEL_PREFIX, app.objectId]]) {
                                    [appListingsForAppSubscription removeObject:appListing];
                                    appSubscribe = YES;
                                }
                                if (appSubscribe) break;
                            }
                        }
                        if (!appSubscribe) {
                            NSLog(@"    Unsubscribing from push channel \"%@\"", channelName);
                            [PFPush unsubscribeFromChannelInBackground:channelName];
                        }
                    }
                }
                if (!subscribedToGeneral) {
                    NSLog(@"  Subscribing to general push channel \"\"");
                    // Subscribe to the global broadcast channel.
                    [PFPush subscribeToChannelInBackground:@""];
                }
                if (!subscribedToUser) {
                    NSLog(@"  Subscribing to user push channel \"%@%@\"", PUSH_USER_CHANNEL_PREFIX, member.objectId);
                    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, member.objectId]];
                }
                if (member.objectId != nil) {
                    for (PFObject * appListing in appListingsForAppSubscription) {
                        PFObject * app = [appListing objectForKey:@"app"];
                        NSLog(@"  Subscribing to app push channel \"%@%@\"", PUSH_APP_CHANNEL_PREFIX, app.objectId);
                        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_APP_CHANNEL_PREFIX, app.objectId]];
                    }
                }
            } else {
                NSLog(@"  Error retrieving existing subscription channels %@", error);
            }
        }];
    };
    
    if (member != nil) {
        PFQuery * appListings = [PFQuery queryWithClassName:@"AppListing"];
        [appListings whereKey:@"member" equalTo:member];
        [appListings whereKey:@"relation" equalTo:PARSE_APP_LISTING_RELATION_DEVELOPER];
        [appListings includeKey:@"app"];
        [appListings findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error && objects.count > 0) {
                [appListingsForAppSubscription addObjectsFromArray:objects];
            }
            
            updateBlock();
            
        }];
    } else {
        updateBlock();
    }
    
}

+ (void) sendPushNotificationFromMember:(PFUser *)memberSource forListingOfApp:(PFObject *)app claimedRelation:(NSString *)relation {
    
    NSMutableDictionary * pushNotificationData = [NSMutableDictionary dictionary];

    NSString * message = nil;
    if ([relation isEqualToString:PARSE_APP_LISTING_RELATION_FAN]) {
        message = [NSString stringWithFormat:@"%@ loves your app %@! keep up the good work!", memberSource.username, [app objectForKey:@"title"]];
    } if ([relation isEqualToString:PARSE_APP_LISTING_RELATION_DEVELOPER]) {
        message = [NSString stringWithFormat:@"%@ claims to be a co-developer of your app %@. [INSERT HOME ADDRESS HERE]", memberSource.username, [app objectForKey:@"title"]];
    }
    [pushNotificationData setObject:message forKey:@"alert"];
    [pushNotificationData setObject:relation forKey:PUSH_RELATION];
    [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_APP_CHANNEL_PREFIX, app.objectId] withData:pushNotificationData];
    
}

@end
