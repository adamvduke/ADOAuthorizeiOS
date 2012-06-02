/*  ADLinkedInOOBViewController.h
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 5/30/12.
 *  Copyright 2011 All rights reserved.
 */

#import "ADOAuthOOBViewController.h"

@interface ADLinkedInOOBViewController : ADOAuthOOBViewController

- (id)initWithConsumerKey:(NSString *)key
           consumerSecret:(NSString *)secret
                 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate;

@end
