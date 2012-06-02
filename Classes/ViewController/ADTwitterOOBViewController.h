/*  ADTwitterOOBViewController.h
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 10/21/11.
 *  Copyright 2011 All rights reserved.
 */

#import "ADOAuthOOBViewController.h"

@interface ADTwitterOOBViewController : ADOAuthOOBViewController

- (id)initWithConsumerKey:(NSString *)key
           consumerSecret:(NSString *)secret
                 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate;
@end
