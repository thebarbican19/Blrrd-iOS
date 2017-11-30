//
//  BDocumentController.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNavigationView.h"

@interface BDocumentController : UIViewController <UIWebViewDelegate, BNavigationDelegate> {
    
}

@property (nonatomic, strong) UIWebView *viewWeb;
@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *file;

@end
