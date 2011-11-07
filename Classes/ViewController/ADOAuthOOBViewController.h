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
	UIWebView *webView;

	@private
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
@property (nonatomic, retain) NSString *verifier;

- (id)initWithConsumerKey:(NSString *)key
		   consumerSecret:(NSString *)secret
	requestTokenURLString:(NSString *)requestTokenURLString
	 accessTokenURLString:(NSString *)accessTokenURLString
	   authorizeURLString:(NSString *)authorizeURLString
				 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate;
@end
