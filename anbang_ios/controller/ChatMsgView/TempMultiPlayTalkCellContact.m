//
//  GroupDetailContactCell.m
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "TempMultiPlayTalkCellContact.h"
#import "TempMultiPlayTalkCellCollection.h"
#import "Contacts.h"
#import "MBProgressHUD.h"



@interface TempMultiPlayTalkCellContact ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, retain) UICollectionViewFlowLayout* layout;
@property (nonatomic, retain) UICollectionView* collectionV;
@property (nonatomic, retain) NSString* membJid;
@property (nonatomic, retain) MBProgressHUD* hub;
@end

@implementation TempMultiPlayTalkCellContact

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _layout = [[UICollectionViewFlowLayout alloc]init];
        //设置item的左右最小距离
        _layout.minimumInteritemSpacing = (self.frame.size.width - 230)/ 5;
        //设置item的上下最小距离
        _layout.minimumLineSpacing = (self.frame.size.width - 230)/ 5;
        //设置item 的范围
        _layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        
        _layout.itemSize = CGSizeMake(50, 68);
        
        _collectionV =  [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_layout];
        
        
        _collectionV.scrollEnabled = NO;
        //配置属性
        _collectionV.backgroundColor = [UIColor whiteColor];
        //设置DataSource 和Delegate
        _collectionV.dataSource = self;
        //    self.collect.separatorColor = [UIColor clearColor];//cell上的线隐藏
        
        _collectionV.delegate = self;
        
        
        [self  addSubview:_collectionV];
        
        //注册cell
        [_collectionV registerClass:[TempMultiPlayTalkCellCollection class] forCellWithReuseIdentifier:@"TempMultiPlayTalkCellCollection"];
      
        
        _hub = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        [self addSubview:_hub];
        
        
    }
    
    
    return self;
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
        return _multiplayerTalkArray.count + 1;
  
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TempMultiPlayTalkCellCollection* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TempMultiPlayTalkCellCollection" forIndexPath:indexPath];
    //       GroupDetailCellCollection* cell = [[GroupDetailCellCollection alloc]initWithFrame: CGRectMake(0, 0, 50, 68)];
    //    [cell setRestorationIdentifier:@"GroupDetailCellCollection"];
    
    if (indexPath.row < _multiplayerTalkArray.count) {
        Contacts* contact = [_multiplayerTalkArray objectAtIndex:indexPath.row];
        cell.avatar = contact.avatar;
        cell.nickName = contact.nickName;
        cell.accountType = contact.accountType;
    }else if(indexPath.row == _multiplayerTalkArray.count){
        cell.addDelect = 0;
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == _multiplayerTalkArray.count){
        [self addLocalGroupMember];
    }else if(indexPath.row < _multiplayerTalkArray.count  ){
        [self showContactInfo];
    }
    
}

-(void)showContactInfo{
    
    if([_delegate respondsToSelector:@selector(showContactInfo:)]){
        [_delegate showContactInfo:self];
    }
    
}


-(void)addLocalGroupMember{
    
    if([_delegate respondsToSelector:@selector(tempMultiPlayTalkCellContact:addMemberSuccess:)]){
        [_delegate tempMultiPlayTalkCellContact:self addMemberSuccess:nil];
    }
    
}


@end
