//
//  ABContactSelectView.m
//  anbang_ios
//
//  Created by yangsai on 15/3/26.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "ABContactSelectView.h"


 

@implementation ABContactSelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self) {
        self = [super initWithFrame:frame];
    }
    
    return self;
}


-(void)defaultSettings{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius=3.0f;
    btn.layer.masksToBounds=YES;
    btn.layer.borderColor=[[UIColor colorWithRed:209.0/255.0 green:192.0/255.0 blue:165.0/255.0 alpha:1.0]CGColor];
    btn.layer.borderWidth= 0.5f;
    btn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [btn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.frame.size.width-imgW - 5 - 2, self.frame.size.height)];
    _titleLabel.font = [UIFont systemFontOfSize:11];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    //_titleLabel.textColor = kTextColor;
    _titleLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:67.0/255.0 blue:62.0/255.0 alpha:1.0];
    [btn addSubview:_titleLabel];
    
    _arrow = [[UIImageView alloc]initWithFrame:CGRectMake(btn.frame.size.width - imgW - 8, (self.frame.size.height-imgH)/2.0, imgW, imgH)];
    _arrow.image = [UIImage imageNamed:_arrowImgName];
    [btn addSubview:_arrow];
    
    //默认不展开
    _isOpen = NO;
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height, self.frame.size.width, 0) style:UITableViewStylePlain];
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.layer.borderWidth = 0.5;
    _listTable.layer.borderColor = kBorderColor.CGColor;
    [_listTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ABContactSelectViewCell"];
    [_supView addSubview:_listTable];
    
    _titleLabel.text = [_titlesList objectAtIndex:_defaultIndex];
    
}
-(void)reloadData{
    [_listTable reloadData];
    _titleLabel.text = [_titlesList objectAtIndex:_defaultIndex];
    
}
-(void)closeOtherCombox{
    for(UIView *subView in _supView.subviews)
    {
        if([subView isKindOfClass:[ABContactSelectView class]]&&subView!=self)
        {
            ABContactSelectView *otherCombox = (ABContactSelectView *)subView;
            if(otherCombox.isOpen)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = otherCombox.listTable.frame;
                    frame.size.height = 0;
                    [otherCombox.listTable setFrame:frame];
                } completion:^(BOOL finished){
                    [otherCombox.listTable removeFromSuperview];
                    otherCombox.isOpen = NO;
                    otherCombox.arrow.transform = CGAffineTransformRotate(otherCombox.arrow.transform, DEGREES_TO_RADIANS(180));
                }];
            }
        }
    }
}
-(void)tapAction{
    //关闭其他combox
    [self closeOtherCombox];
    
    if(_isOpen)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _listTable.frame;
            frame.size.height = 0;
            [_listTable setFrame:frame];
        } completion:^(BOOL finished){
            [_listTable removeFromSuperview];//移除
            _isOpen = NO;
            _arrow.transform = CGAffineTransformRotate(_arrow.transform, DEGREES_TO_RADIANS(180));
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            if(_titlesList.count>0)
            {
                /*
                 
                 注意：如果不加这句话，下面的操作会导致_listTable从上面飘下来的感觉：
                 _listTable展开并且滑动到底部 -> 点击收起 -> 再点击展开
                 */
                [_listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            
            [_supView addSubview:_listTable];
            [_supView bringSubviewToFront:_listTable];//避免被其他子视图遮盖住
            CGRect frame = _listTable.frame;
            frame.size.height = _tableHeight>0?_tableHeight:tableH;
            float height = [UIScreen mainScreen].bounds.size.height;
            if(frame.origin.y+frame.size.height>height)
            {
                //避免超出屏幕外
                frame.size.height -= frame.origin.y + frame.size.height - height;
            }
            [_listTable setFrame:frame];
        } completion:^(BOOL finished){
            _isOpen = YES;
            _arrow.transform = CGAffineTransformRotate(_arrow.transform, DEGREES_TO_RADIANS(180));
        }];
    }

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titlesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ABContactSelectViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [_titlesList objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _titleLabel.text = [_titlesList objectAtIndex:indexPath.row];
    _isOpen = YES;
    [self tapAction];
    if([_delegate respondsToSelector:@selector(selectAtIndex:inCombox:)])
    {
        [_delegate selectAtIndex:indexPath.row inCombox:self];
    }
    [self performSelector:@selector(deSelectedRow) withObject:nil afterDelay:0.2];
}

-(void)deSelectedRow
{
    [_listTable deselectRowAtIndexPath:[_listTable indexPathForSelectedRow] animated:YES];
}

@end
