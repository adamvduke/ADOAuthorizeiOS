/*  ADOAuthOOBViewController.h
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 1/13/11.
 *  Copyright 2011 All rights reserved.
 */

#import <UIKit/UIKit.h>

@class OAConsumer;
@class OAToken;

@protocol ADOAuthOOBViewControllerDelegate<NSObject>

- (void)authCompletedWithData:(NSString *)authData orError:(NSError *)error;
- (void)authCancelled;

@end

@interface ADOAuthOOBViewController : UIViewController <UIWebViewDelegate> {
    @private
    UIWebView *webView;
    UIToolbar *toolBar;
    NSURL *requestTokenURL;
    NSURL *accessTokenURL;
    NSURL *authorizeURL;

    OAConsumer *consumer;
    OAToken *requestToken;
    NSString *verifier;

    BOOL firstLoad;
    id<ADOAuthOOBViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, assign) id<ADOAuthOOBViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *verifier;
@property (nonatomic, assign) BOOL firstLoad;

/* Designated initializer */
- (id)initWithConsumerKey:(NSString *)key
           consumerSecret:(NSString *)secret
                 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate;

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 * A valid implementation should return a javascript snippet that scrapes the
 * pin out of the web view after the user has authorized the application.
 */
- (NSString *)javascriptToLocateOAuthVerifier;

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)requestTokenURLString;

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)accessTokenURLString;

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)authorizeTokenURLString;

@end
