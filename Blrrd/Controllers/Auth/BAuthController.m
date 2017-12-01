//
//  BAuthController.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAuthController.h"
#import "BConstants.h"

@interface BAuthController ()

@end

@implementation BAuthController

-(NSString *)value:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSDictionary *data = [[self.formdata filteredArrayUsingPredicate:predicate] firstObject];
    if ([data objectForKey:@"content"] == nil) return @"";
    else return [data objectForKey:@"content"];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)viewDismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    
    self.credentials = [[BCredentialsObject alloc] init];

    self.statusbarstyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;

    viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:self.view.bounds];
    viewPlaceholder.delegate = self;
    viewPlaceholder.backgroundColor = MAIN_BACKGROUND_COLOR;
    viewPlaceholder.gesture = true;
    viewPlaceholder.spinner = true;
    viewPlaceholder.textcolor = [UIColor whiteColor];
    viewPlaceholder.alpha = 0.0;
    viewPlaceholder.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [self.view addSubview:viewPlaceholder];
    
    viewHeader = [[BAuthenticationHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 220.0)];
    viewHeader.backgroundColor = [UIColor clearColor];
    viewHeader.delegate = self;
    [self.view addSubview:viewHeader];

    viewForm = [[UITableView alloc] initWithFrame:CGRectMake(30.0, viewHeader.bounds.size.height + 20.0, self.view.bounds.size.width - 60.0, self.view.bounds.size.height - viewHeader.bounds.size.height)];
    viewForm.delegate = self;
    viewForm.dataSource = self;
    viewForm.backgroundColor = [UIColor clearColor];
    viewForm.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewForm.bounds.size.width, 35.0)];
    viewForm.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewForm.bounds.size.width, 100.0)];
    viewForm.separatorColor = [UIColor clearColor];
    viewForm.scrollEnabled = true;
    viewForm.alpha = 0.5;
    viewForm.showsVerticalScrollIndicator = false;
    [self.view addSubview:viewForm];
    [viewForm registerClass:[BAutheticateFormCell class] forCellReuseIdentifier:@"form"];
    
    viewAction = [[UIButton alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height - 85.0, self.view.bounds.size.width - 40.0, 60.0)];
    viewAction.backgroundColor = UIColorFromRGB(0x27CAE1);
    viewAction.clipsToBounds = true;
    viewAction.layer.cornerRadius = 5.0;
    [viewAction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:14]];
    [viewAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:viewAction];

    [self setNeedsStatusBarAppearanceUpdate];
    [self viewSetup:true];
    [self setLogin:true];
    [self viewShowSignupForm];
    
}

-(void)viewShowLoginForm {
    if (self.login == false) {
        CGRect formframe = viewForm.frame;
        formframe.origin.y = viewHeader.bounds.size.height + 20.0;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [viewForm setFrame:formframe];
            [viewForm setAlpha:0.0];

        } completion:^(BOOL finished) {
            CGRect formframe = viewForm.frame;
            formframe.origin.y = viewHeader.bounds.size.height;
            [self viewSetup:!self.login];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [viewForm setFrame:formframe];
                [viewForm setAlpha:1.0];

            } completion:nil];
            
        }];
        
    }
    
    [viewAction setTitle:NSLocalizedString(@"Authentication_LoginAction_Title", nil) forState:UIControlStateNormal];
    [viewAction addTarget:self action:@selector(viewAuthenticate) forControlEvents:UIControlEventTouchUpInside];
    [self setLogin:true];
    
}

-(void)viewShowSignupForm {
    if (self.login) {
        CGRect formframe = viewForm.frame;
        formframe.origin.y = viewHeader.bounds.size.height + 20.0;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [viewForm setFrame:formframe];
            [viewForm setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            CGRect formframe = viewForm.frame;
            formframe.origin.y = viewHeader.bounds.size.height;
            [self viewSetup:!self.login];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [viewForm setFrame:formframe];
                [viewForm setAlpha:1.0];
                
            } completion:nil];
            
        }];
        
    }
    
    [viewAction setTitle:NSLocalizedString(@"Authentication_SignupAction_Title", nil) forState:UIControlStateNormal];
    [viewAction addTarget:self action:@selector(viewSignup) forControlEvents:UIControlEventTouchUpInside];
    [self setLogin:false];
    
}

-(void)viewSetup:(BOOL)signup {
    self.formdata = [[NSMutableArray alloc] init];
    if (signup) {
        [self.formdata addObject:@{@"key":@"email",
                                   @"placeholder":NSLocalizedString(@"Authentication_FormEmail_Placeholder", nil),
                                   @"title":NSLocalizedString(@"Authentication_FormEmail_Title", nil),
                                   @"content":@""}];
        [self.formdata addObject:@{@"key":@"username",
                                   @"placeholder":NSLocalizedString(@"Authentication_FormUsername_Placeholder", nil),
                                   @"title":NSLocalizedString(@"Authentication_FormUsername_Title", nil),
                                   @"content":@""}];
        [self.formdata addObject:@{@"key":@"password",
                                   @"placeholder":NSLocalizedString(@"Authentication_FormPassword_Placeholder", nil),
                                   @"title":NSLocalizedString(@"Authentication_FormPassword_Title", nil),
                                   @"content":@""}];

    }
    else {
        [self.formdata addObject:@{@"key":@"username",
                                   @"placeholder":NSLocalizedString(@"Authentication_FormUsername_Placeholder", nil),
                                   @"title":NSLocalizedString(@"Authentication_FormUsername_Title", nil),
                                   @"content":@""}];
        [self.formdata addObject:@{@"key":@"password",
                                   @"placeholder":NSLocalizedString(@"Authentication_FormPassword_Placeholder", nil),
                                   @"title":NSLocalizedString(@"Authentication_FormPassword_Title", nil),
                                   @"content":@""}];
        
    }
    
    [viewForm reloadData];
    
}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    if ([viewPlaceholder.key isEqualToString:@"error"]) {
        [self viewHandlePlaceholder:false];
        
    }
    
}

-(void)viewHandlePlaceholder:(BOOL)present {
    if (present) {
        [self.view bringSubviewToFront:viewPlaceholder];
        [self.view endEditing:true];
        
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:present?UIViewAnimationOptionCurveEaseIn:UIViewAnimationOptionCurveEaseOut animations:^{
        [viewPlaceholder setTransform:CGAffineTransformMakeScale(present?1.0:1.2, present?1.0:1.2)];
        [viewPlaceholder setAlpha:present?1.0:0.0];
        
    } completion:^(BOOL finished) {
        if (!present) [self.view sendSubviewToBack:viewPlaceholder];

    }];
    
}

-(void)viewAuthenticate {
    [viewPlaceholder setKey:@"loading"];
    [self viewHandlePlaceholder:true];
    [self.query authenticationLoginWithCredentials:@{@"username":[self value:@"username"],
                                                     @"password":[self value:@"password"]} completion:^(NSDictionary *user, NSError *error) {
        if (error.code == 200 && user) {
            [viewPlaceholder setKey:@"sucsess"];
            [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusSucsess_Title", nil) instructions:NSLocalizedString(@"Authentication_StatusSucsess_Text", nil)];
            [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                if (error.code == 200) [self viewDismiss];
                else {
                    [viewPlaceholder setKey:@"error"];
                    [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusError_Title", nil) instructions:error.domain];
                    
                }
                
            }];
            
        }
        else {
            [viewPlaceholder setKey:@"error"];
            [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusError_Title", nil) instructions:error.domain];
            
        }
        
    }];
    
}

-(void)viewSignup {
    [viewPlaceholder setKey:@"loading"];
    [viewPlaceholder placeholderLoading:0.6];
    [self viewHandlePlaceholder:true];
    [self.query authenticationSignupWithCredentials:@{@"username":[self value:@"username"],
                                                      @"password":[self value:@"password"],
                                                      @"email":[self value:@"email"],
                                                      @"pushId":@""} completion:^(NSDictionary *user, NSError *error) {
        if (error.code == 200) {
            [viewPlaceholder setKey:@"sucsess"];
            [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusSucsess_Title", nil) instructions:NSLocalizedString(@"Authentication_StatusSucsess_Text", nil)];
            [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                if (error.code == 200) [self viewDismiss];
                else {
                    [viewPlaceholder setKey:@"error"];
                    [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusError_Title", nil) instructions:error.domain];

                }
                
            }];
            
        }
        else {
            [viewPlaceholder setKey:@"error"];
            [viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_StatusError_Title", nil) instructions:error.domain];
            
        }
         
        
    }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.formdata.count;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BAutheticateFormCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.label setFrame:CGRectMake(20.0, 4.0, cell.contentView.bounds.size.width - 40.0 , 10.0)];
    [cell.input setFrame:CGRectMake(10.0, 22.0, cell.contentView.bounds.size.width - 20.0, cell.contentView.bounds.size.height - 34.0)];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.formdata objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    NSString *placeholder = [item objectForKey:@"placeholder"];
    NSString *title = [item objectForKey:@"title"];

    BAutheticateFormCell *cell = (BAutheticateFormCell *)[tableView dequeueReusableCellWithIdentifier:@"form" forIndexPath:indexPath];
 
    [cell.label setText:title.uppercaseString];    
    [cell.input setTag:indexPath.row];
    [cell.input setPlaceholder:placeholder];

    if (indexPath.row == (self.formdata.count - 1)) [cell.input setReturnKeyType:UIReturnKeyJoin];
    else [cell.input setReturnKeyType:UIReturnKeyNext];
    
    if ([key isEqualToString:@"password"]) [cell.input setSecureTextEntry:true];
    else [cell.input setSecureTextEntry:false];
    
    if ([key isEqualToString:@"email"]) [cell.input setKeyboardType:UIKeyboardTypeEmailAddress];
    else [cell.input setKeyboardType:UIKeyboardTypeDefault];
    
    [cell setDelegate:self];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
}

-(void)textFieldKeyboardWasShow:(NSNotification *)notification {
    viewKeyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [viewHeader setFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 120.0)];
        [viewHeader resize];
        [viewForm setFrame:CGRectMake(30.0, viewHeader.bounds.size.height, self.view.bounds.size.width - 60.0, self.view.bounds.size.height - (viewKeyboard.height + viewHeader.bounds.size.height))];
        [viewAction setFrame:CGRectMake(20.0, self.view.bounds.size.height - (viewKeyboard.height + 75.0), self.view.bounds.size.width - 40.0, 60.0)];

    } completion:nil];

}

-(void)textFieldKeyboardWasHidden:(NSNotification *)notification {
    viewKeyboard = CGSizeZero;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [viewHeader setFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 220.0)];
        [viewHeader resize];
        [viewForm setFrame:CGRectMake(30.0, viewHeader.bounds.size.height, self.view.bounds.size.width - 60.0, self.view.bounds.size.height - viewHeader.bounds.size.height)];
        [viewAction setFrame:CGRectMake(20.0, self.view.bounds.size.height - 85.0, self.view.bounds.size.width - 40.0, 60.0)];

    } completion:nil];
    
}

-(void)textFieldDidReturn:(UITextField *)textField {
    if (textField.tag == (self.formdata.count - 1)) {
        BAutheticateFormCell *cell = (BAutheticateFormCell *)[viewForm cellForRowAtIndexPath: [NSIndexPath indexPathForRow:textField.tag inSection:0]];
        [cell.input resignFirstResponder];
        
        if (self.login) [self viewAuthenticate];

    }
    else {
        BAutheticateFormCell *cell = (BAutheticateFormCell *)[viewForm cellForRowAtIndexPath: [NSIndexPath indexPathForRow:textField.tag + 1 inSection:0]];
        [cell.input becomeFirstResponder];

    }
    
}

-(void)textFieldDidChange:(NSNotification *)notification {
    UITextField *selected = (UITextField *)notification.object;
    NSLog(@"selected %@" ,selected);
    NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:[self.formdata objectAtIndex:selected.tag]];
    [append setObject:selected.text forKey:@"content"];
    [self.formdata replaceObjectAtIndex:selected.tag withObject:append];
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return self.statusbarhidden;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusbarstyle;
    
}

@end
