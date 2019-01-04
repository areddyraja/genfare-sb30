//
//  PayAsYouGoCell.m
//  CDTATicketing
//
//  Created by CooCooTech on 8/26/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "PayAsYouGoCell.h"
#import "Singleton.h"
#import "AppConstants.h"

@interface PayAsYouGoCell (){
    NSTimer *timer;
}
@end
@implementation PayAsYouGoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)startTimer{
    if(timer){
        [timer invalidate];
        timer=nil;
    }
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
        timer= [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [[Singleton sharedManager] checkProductsFOrCell:[NSArray arrayWithObjects:self,self.prod, nil]];
        }];
    }else{
        timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(checkproduct) userInfo:nil repeats:YES];
    }
//    timer= [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [[Singleton sharedManager] checkProductsFOrCell:[NSArray arrayWithObjects:self,self.prod, nil]];
//    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)checkproduct{
    [[Singleton sharedManager] checkProductsFOrCell:[NSArray arrayWithObjects:self,self.prod, nil]];
}

@end
