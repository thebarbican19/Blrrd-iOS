//
//  BChannelController.h
//  Blrrd
//
//  Created by Joe Barbour on 14/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BChannelDelegate;
@interface BChannelController : UICollectionViewController

@property (nonatomic, strong) id <BChannelDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *channels;

-(void)viewSetupContent:(NSArray *)content;

@end

@protocol BChannelDelegate <NSObject>

@optional

-(void)viewPresentChannel:(NSDictionary *)channel;

@end

