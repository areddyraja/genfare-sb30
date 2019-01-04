//
//  SavedCardsTableViewCell.m
//  CooCooBase
//
//  Created by Gaian Solutions on 4/17/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "SavedCardsTableViewCell.h"
#import  "NSBundle+BaseResourcesBundle.h"
#import "UIImage+LoadOverride.h"
#import "DeleteCardApi.h"
@implementation SavedCardsTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        self = [nib objectAtIndex:0];
        
    }
    return self;
}



 - (void)awakeFromNib {
    [super awakeFromNib];
    
   NSBundle *resbundle =  [NSBundle baseResourcesBundle];

    if(resbundle==nil){
        return;
    }
     NSURL *url = [resbundle URLForResource:@"deleteCard" withExtension:@"png"];
    
    NSURL *gradienturl = [resbundle URLForResource:@"gradientbg" withExtension:@"png"];
     
    
    [self.CardBgview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:gradienturl]]]];
//    [self.deleteButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] forState:UIControlStateNormal];
    [self.deleteButton setImage:[UIImage loadOverrideImageNamed:@"deleteCard"] forState:UIControlStateNormal];
     
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
