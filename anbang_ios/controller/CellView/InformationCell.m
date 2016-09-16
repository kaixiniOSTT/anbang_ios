//
//  InformationCell.m
//  anbang_ios
//
//  Created by seeko on 14-3-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "InformationCell.h"

@implementation InformationCell
@synthesize labLeftText,labRigitText;
@synthesize headImage,codeImage;
@synthesize RigitText,LeftText;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        labLeftText=[[UILabel alloc]initWithFrame:CGRectMake(15, 0, 180, 20)];
        [labLeftText setBackgroundColor:[UIColor clearColor]];
        labLeftText.textColor = AB_Color_403b36;
        labLeftText.font = AB_FONT_15;
        CGPoint center = labLeftText.center;
        center.y = self.frame.size.height / 2;
        labLeftText.center = center;
        [self.contentView addSubview:labLeftText];
        labRigitText=[[UILabel alloc]initWithFrame:CGRectMake(KCurrWidth/2-50-35, self.contentView.frame.size.height/2-10, KCurrWidth/2 + 50, 20)];
        labRigitText.textColor = AB_Color_9c958a;;
        [labRigitText setBackgroundColor:[UIColor clearColor]];
//        labRigitText.text=@"labRigitText";
        labRigitText.font = AB_FONT_15;
        labRigitText.textAlignment=NSTextAlignmentRight;
        labRigitText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:labRigitText];
        headImage=[[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth-70, 15, 35, 35)];
        [self.contentView addSubview:headImage];
        codeImage=[[UIImageView alloc]initWithFrame:CGRectMake(KCurrWidth-60, 12, 20, 20)];
        [self.contentView addSubview:codeImage];
        
    }
    return self;
}

//Label.numberOfLines = 0 //动态显示UILabel的行数
//
//Label.lineBreakMode = UILineBreakModeWordWrap; //设置UILabel换行模式


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//重新set方法
-(void)setLeftText:(NSString *)l{
    if (![l isEqualToString:LeftText]) {
        LeftText=[l copy];
        labLeftText.text=LeftText;
    }
}

-(void)setRigitText:(NSString *)r{
    if (![r isEqualToString:RigitText]) {
        RigitText=[r copy];
        labRigitText.text=RigitText;
    }
}
//- (void)changeRightLabel{
//    CGRect rightFrame = RigitText.
//    
//}

@end
