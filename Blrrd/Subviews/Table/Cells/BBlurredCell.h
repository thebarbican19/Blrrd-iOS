//
//  BBlurredCell.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>
#import <UIImageView+WebCache.h>
#import <Mixpanel.h>
#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "SAMLabel.h"
#import "GDStatusLabel.h"

@protocol BBlurredCellDelegate;
@interface BBlurredCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <BBlurredCellDelegate> delegate;
@property (nonatomic ,strong) Mixpanel *mixpanel;
@property (nonatomic ,strong) BQueryObject *query;
@property (nonatomic ,strong) BCredentialsObject *credentials;
@property (nonatomic ,strong) NSMutableDictionary *content;
@property (nonatomic ,strong) NSMutableDictionary *userdata;
@property (nonatomic ,assign) int timeviewed;
@property (nonatomic ,assign) int existingtimeviewed;
@property (nonatomic ,assign) BOOL imagerevealed;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) NSIndexPath *indexpath;

@property (nonatomic ,strong) UIView *container;
@property (nonatomic ,strong) UIImageView *image;
@property (nonatomic ,strong) UIImageView *overlay;
@property (nonatomic ,strong) SAMLabel *subtitle;
@property (nonatomic ,strong) UILabel *user;
@property (nonatomic ,strong) UIView *userarea;
@property (nonatomic ,strong) SAMLabel *timestamp;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIView *avatarbackground;
@property (nonatomic ,strong) GDStatusLabel *time;
@property (nonatomic ,strong) UIButton *options;
@property (nonatomic ,strong) UITapGestureRecognizer *gesture;
@property (nonatomic ,strong) UINotificationFeedbackGenerator *feedback;
@property (nonatomic ,strong) UITapGestureRecognizer *profilegesture;

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index;
-(void)reveal:(UILongPressGestureRecognizer *)gesture;

@end

@protocol BBlurredCellDelegate <NSObject>

@optional

-(void)collectionViewRevealed:(BBlurredCell *)revealed;
-(void)collectionViewPresentOptions:(BBlurredCell *)item;
-(void)collectionViewPresentProfile:(BBlurredCell *)item;

@end
