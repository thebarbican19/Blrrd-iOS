//
//  LKFeedbackController.m
//  Lynker
//
//  Created by Joe Barbour on 01/09/2015.
//  Copyright (c) 2015 Lynker. All rights reserved.
//

#import "GDFeedbackController.h"
#import "BConstants.h"

@interface GDFeedbackController ()

@end

@implementation GDFeedbackController

-(BOOL)shouldAutorotate {
    return false;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self.feedbackEntry becomeFirstResponder];
    [self.feedbackNavigation navigationTitle:self.header];
    [self.mixpanel track:@"App Feedback Form Viewed" properties:@{@"type":self.type}];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (button.tag == 0) [self.navigationController popViewControllerAnimated:true];
    else [self navigationRightButtonWasTapped:button];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.device = [GBDeviceInfo deviceInfo];
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    self.feedbackNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.feedbackNavigation.backgroundColor = [UIColor clearColor];
    self.feedbackNavigation.name = @"Feeback";
    self.feedbackNavigation.delegate = self;
    self.feedbackNavigation.rightbutton = NSLocalizedString(@"Settings_FeedbackSend_Action", nil);
    [self.view addSubview:self.feedbackNavigation];
    
    self.feedbackPlaceholder = [[GDPlaceholderView alloc] initWithFrame:self.view.bounds];
    self.feedbackPlaceholder.delegate = self;
    self.feedbackPlaceholder.backgroundColor = [UIColor clearColor];
    self.feedbackPlaceholder.gesture = true;
    self.feedbackPlaceholder.textcolor = [UIColor whiteColor];
    self.feedbackPlaceholder.hidden = true;
    [self.view addSubview:self.feedbackPlaceholder];
    
    self.feedbackEntry = [[UITextView alloc] initWithFrame:CGRectMake(0.0, self.feedbackNavigation.bounds.size.height + 10.0, self.view.bounds.size.width, 100.0)];
    self.feedbackEntry.text = self.message;
    self.feedbackEntry.backgroundColor = [UIColor clearColor];
    self.feedbackEntry.placeholder = self.placeholder;
    self.feedbackEntry.placeholderColor = UIColorFromRGB(0x9CA0A5);
    self.feedbackEntry.delegate = self;
    self.feedbackEntry.returnKeyType = UIReturnKeyDefault;
    self.feedbackEntry.textColor = [UIColor whiteColor];
    self.feedbackEntry.keyboardType = UIKeyboardTypeDefault;
    self.feedbackEntry.textContainerInset = UIEdgeInsetsMake(16.0, 20.0, 16.0, 20.0);
    self.feedbackEntry.font = [UIFont fontWithName:@"Nunito-SemiBold" size:16];
    self.feedbackEntry.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.view addSubview:self.feedbackEntry];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self.navigationController popViewControllerAnimated:true];

}

-(void)textFieldDidShow:(NSNotification*)notification {
    feedbackKeyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    feedbackFrame = self.feedbackEntry.frame;
    feedbackFrame.size.height = self.view.bounds.size.height - (feedbackKeyboard.size.height + (self.feedbackNavigation.bounds.size.height + 20.0));
    [UIView animateWithDuration:0.3 animations:^{
        self.feedbackEntry.frame = feedbackFrame;

    }];

}

-(void)textFieldDidHide:(NSNotification*)notification {
    feedbackKeyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    feedbackFrame = self.feedbackEntry.frame;
    feedbackFrame.size.height = self.view.bounds.size.height - (feedbackKeyboard.size.height + (self.feedbackNavigation.bounds.size.height + 20.0));
    [UIView animateWithDuration:0.3 animations:^{
        self.feedbackEntry.frame = feedbackFrame;
        
    }];
    
}

-(void)navigationRightButtonWasTapped:(UIButton *)button {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:true];
    
    if ([self.feedbackEntry.text length] < 5) {
        [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.feedbackEntry.center.x - 3,self.feedbackEntry.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.feedbackEntry.center.x + 3, self.feedbackEntry.center.y)]];
        [self.feedbackEntry.layer addAnimation:shake forKey:@"position"];
        [self.feedbackEntry becomeFirstResponder];
        [self.feedbackNavigation navigationTitle:NSLocalizedString(@"Settings_FeedbackEmptyMessage_Text", nil)];
        
    }
    else {
        [self.feedbackEntry resignFirstResponder];
        [self.feedbackEntry setFrame:feedbackFrame];
        [self viewShouldPostMessage:self.type];
        
    }
    
}

-(void)viewShouldPostMessage:(NSString *)type {
    NSMutableArray *attachement = [[NSMutableArray alloc] init];
    [attachement addObject:@{@"title":@"Message",
                             @"text":self.feedbackEntry.text,
                             @"color":@"#"}];
    [attachement addObject:@{@"title":@"User Information",
                             @"text":[NSString stringWithFormat:@"Name: %@\nEmail: %@\nKey: %@\n\nLanguage: %@\nApp Version: %@\niOS Build: %@\niOS Version: %@\nDevice: %@\nMixpanel: %@" ,
                                      self.credentials.userHandle,
                                      self.credentials.userEmail,
                                      self.credentials.userKey,
                                      APP_LANGUAGE,
                                      APP_VERSION,
                                      APP_BUILD,
                                      APP_DEVICE,
                                      self.device.modelString,
                                      self.mixpanel.distinctId],
                             @"color":@"#"}];
    
    NSString *channel = @"C88CT9DC7";
    NSString *title = [NSString stringWithFormat:@"A *%@* %@ message received from *%@*" ,APP_BUNDLE_NAME ,type.capitalizedString, self.credentials.userHandle];
    NSURL *sessionURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://hooks.slack.com/services/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"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *sessionRequest = [NSMutableURLRequest requestWithURL:sessionURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [sessionRequest setHTTPMethod:@"POST"];
    [sessionRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:@{@"channel":channel, @"text":title, @"attachments":attachement, @"response_type":@"in_channel"} options:NSJSONWritingPrettyPrinted error:nil]];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:sessionRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data.length > 0 && [[NSString stringWithUTF8String:data.bytes] isEqualToString:@"ok"]) {
            [self.feedbackEntry setHidden:true];
            [self.feedbackPlaceholder setHidden:false];
            [self.feedbackPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Settings_FeedbackPlaceholderSent_Title", nil) instructions:NSLocalizedString(@"Settings_FeedbackPlaceholderSent_Body", nil)];

            [self.mixpanel track:@"App Sent Feedback" properties:nil];
    
        }
        else {
            [self.feedbackEntry becomeFirstResponder];
            [self.feedbackNavigation navigationTitle:error.domain];

        }
        
    }];
    
    [sessionTask resume];
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return false;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}


@end
