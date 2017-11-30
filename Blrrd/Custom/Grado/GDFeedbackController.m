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

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.device = [GBDeviceInfo deviceInfo];
    
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    self.feedbackNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.feedbackNavigation.backgroundColor = [UIColor clearColor];
    self.feedbackNavigation.name = @"Feeback";
    self.feedbackNavigation.delegate = self;
    [self.view addSubview:self.feedbackNavigation];
    
    self.feedbackPlaceholder = [[GDPlaceholderView alloc] initWithFrame:CGRectMake(0.0, self.feedbackNavigation.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.feedbackNavigation.bounds.size.height)];
    self.feedbackPlaceholder.delegate = self;
    self.feedbackPlaceholder.backgroundColor = [UIColor clearColor];
    self.feedbackPlaceholder.gesture = true;
    self.feedbackPlaceholder.hidden = true;
    [self.view addSubview:self.feedbackPlaceholder];
    
    self.feedbackEntry = [[UITextView alloc] initWithFrame:CGRectMake(0.0, self.feedbackNavigation.bounds.size.height + 10.0, self.view.bounds.size.width, 100.0)];
    self.feedbackEntry.text = self.message;
    self.feedbackEntry.backgroundColor = self.feedbackEmail.backgroundColor;
    self.feedbackEntry.placeholder = self.placeholder==nil?NSLocalizedString(@"FeedbackPlaceholderTitle", nil):self.placeholder;
    self.feedbackEntry.placeholderColor = UIColorFromRGB(0x9CA0A5);
    self.feedbackEntry.delegate = self;
    self.feedbackEntry.returnKeyType = UIReturnKeyDefault;
    self.feedbackEntry.textColor = self.feedbackEmail.textColor;
    self.feedbackEntry.keyboardType = UIKeyboardTypeDefault;
    self.feedbackEntry.textContainerInset = UIEdgeInsetsMake(12.0, 10.0, 12.0, 10.0);
    self.feedbackEntry.font = self.feedbackEmail.font;
    self.feedbackEntry.layer.borderColor = self.feedbackEmail.layer.borderColor;
    self.feedbackEntry.layer.borderWidth = self.feedbackEmail.layer.borderWidth;
    self.feedbackEntry.keyboardAppearance = self.feedbackEmail.keyboardAppearance;
    [self.view addSubview:self.feedbackEntry];
    
    /*
    self.feedbackAction = [[SHAlertView alloc] init];
    self.feedbackAction.view.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.feedbackAction.delegate = self;
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self.navigationController popViewControllerAnimated:true];

}

-(void)textFieldDidShow:(NSNotification*)notification {
    feedbackKeyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    feedbackFrame = self.feedbackEntry.frame;
    feedbackFrame.size.height = self.view.bounds.size.height - (feedbackKeyboard.size.height + (self.feedbackNavigation.bounds.size.height + (self.feedbackEmail.hidden==true?20.0:self.feedbackEmail.bounds.size.height + 40.0)));
    [UIView animateWithDuration:0.3 animations:^{
        self.feedbackEntry.frame = feedbackFrame;

    }];

}

-(void)textFieldDidHide:(NSNotification*)notification {
    feedbackKeyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    feedbackFrame = self.feedbackEntry.frame;
    feedbackFrame.size.height = self.view.bounds.size.height - (feedbackKeyboard.size.height + (self.feedbackNavigation.bounds.size.height + (self.feedbackEmail.hidden==true?20.0:self.feedbackEmail.bounds.size.height + 40.0)));
    [UIView animateWithDuration:0.3 animations:^{
        self.feedbackEntry.frame = feedbackFrame;
        
    }];
    
}


-(void)navigationLeftButtonWasTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
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

        //[self.feedbackNavigation navigationUpdateTitle:@"Please enter a message"];
        
    }
    else {
        [self.feedbackEmail resignFirstResponder];
        [self.feedbackEntry resignFirstResponder];
        [self.feedbackEntry setFrame:feedbackFrame];
        
        /*
        if (self.type == nil && self.service == GDMessageServiceTypeSlack) {
            [self.feedbackAction setTitleheader:NSLocalizedString(@"FeedbackActionHeader", nil)];
            [self.feedbackAction setKey:@"type"];
            [self.feedbackAction setButtons:@[@{@"key":@"general", @"title":NSLocalizedString(@"FeedbackGeneral", nil)},
                                              @{@"key":@"question", @"title":NSLocalizedString(@"FeedbackQuestion", nil)},
                                              @{@"key":@"press", @"title":NSLocalizedString(@"FeedbackPress", nil)},
                                              @{@"key":@"bug", @"title":NSLocalizedString(@"FeedbackBug", nil)},
                                              @{@"key":@"other", @"title":NSLocalizedString(@"FeedbackOther", nil)}]];
            [self.feedbackAction present];
            
        }
        else {
            [self viewShouldPostMessage:self.type];
            [self.feedbackNavigation navigationButtonImage:nil tag:0];
            
        }
        */
    
    }

}

/*
-(void)viewAlertViewTapped:(SHAlertView *)alert index:(NSInteger)index {
    if (index != 99) {
        [self setType:[[alert.buttons objectAtIndex:index] objectForKey:@"title"]];
        [self viewShouldPostMessage:self.type];
        [self.feedbackNavigation navigationButtonHidden:true tag:1];

    }
    else [self.feedbackEntry becomeFirstResponder];
    
}
*/

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
    
    NSString *channel;
    if ([type isEqualToString:@"error"]) channel = @"C0FJJ2JCF";
    else channel = @"C88CT9DC7";
    
    NSString *title = [NSString stringWithFormat:@"A *%@* %@ message received from *%@*" ,APP_BUNDLE_NAME ,type.capitalizedString, self.credentials.userHandle];
    NSURL *sessionURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://hooks.slack.com/services/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"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *sessionRequest = [NSMutableURLRequest requestWithURL:sessionURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [sessionRequest setHTTPMethod:@"POST"];
    [sessionRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:@{@"channel":channel, @"text":title, @"attachments":attachement, @"response_type":@"in_channel"} options:NSJSONWritingPrettyPrinted error:nil]];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:sessionRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data.length > 0 && [[NSString stringWithUTF8String:data.bytes] isEqualToString:@"ok"]) {
            [self.feedbackEntry setHidden:true];
            [self.feedbackEmail setHidden:true];
            [self.feedbackPlaceholder setHidden:false];
            [self.feedbackPlaceholder placeholderUpdateTitle:@"Lovely jubbly!" instructions:@"Thanks, message has been sent. Tap to close this window"];
            
            [self.mixpanel track:@"App Sent Feedback" properties:nil];
    
        }
        else {
            [self.feedbackEntry becomeFirstResponder];
            //[self.feedbackNavigation navigationUpdateTitle:error.domain];
            //[self.feedbackNavigation navigationButtonHidden:false tag:1];

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
