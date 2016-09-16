//
//  GroupDetailContactCell.m
//  anbang_ios
//
//  Created by yangsai on 15/3/29.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "GroupDetailCellContact.h"
#import "GroupDetailCellCollection.h"
#import "Contacts.h"
#import "MBProgressHUD.h"
#import "ContactInfo.h"

@interface GroupDetailCellContact ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
@property (nonatomic, retain) UICollectionViewFlowLayout* layout;
@property (nonatomic, retain) UICollectionView* collectionV;
@property (nonatomic, retain) NSString* membJid;
@property (nonatomic, retain) MBProgressHUD* hub;
//@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation GroupDetailCellContact

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CNN_Group_Delete_GroupMember" object:nil];
}

- (id)initWithFrame:(CGRect)frame{
    
   
    
    self = [super initWithFrame:frame];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLocalGroupMember) name:@"CNN_Group_Delete_GroupMember" object:nil];
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
        
        
        //注册cell
        [_collectionV registerClass:[GroupDetailCellCollection class] forCellWithReuseIdentifier:@"GroupDetailCellCollection"];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collectionViewClick:)];
        [_collectionV addGestureRecognizer:tap];
        
        tap.delegate = self;
        //添加到父视图
        [self  addSubview:_collectionV];
        
        _hub = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        [self addSubview:_hub];
        
        // self.queue = dispatch_queue_create("group.detail.cell.nickname.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    
    return self;

}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    
//    if (self) {
//        _layout = [[UICollectionViewFlowLayout alloc]init];
//        //设置item的左右最小距离
//        _layout.minimumInteritemSpacing = 20;
//        //设置item的上下最小距离
//        _layout.minimumLineSpacing = 20;
//        //设置item 的范围
//        //_layout.sectionInset = UIEdgeInsetsMake(0, 0, 68, self.);
//        
//        _collectionV =  [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 400) collectionViewLayout:_layout];
//        
//        _collectionV.scrollEnabled = NO;
//        //配置属性
//        _collectionV.backgroundColor = [UIColor redColor];
//        //设置DataSource 和Delegate
//        _collectionV.dataSource = self;
//        //    self.collect.separatorColor = [UIColor clearColor];//cell上的线隐藏
//        
//        _collectionV.delegate = self;
//        
//        //注册cell
//        [_collectionV registerClass:[GroupDetailCellCollection class] forCellWithReuseIdentifier:@"GroupDetailCellCollection"];
//        
//        
//        //添加到父视图
//        [self  addSubview:_collectionV];
//    }
//    
//    
//    return self;
//
//}
//

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_isAB){
        return _contacts.count;
    }else{
        if(_isAdmin){
            return _contacts.count + 2;
        }else{
            return _contacts.count + 1;
        }
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   GroupDetailCellCollection* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupDetailCellCollection" forIndexPath:indexPath];
//    GroupDetailCellCollection* cell = [[GroupDetailCellCollection alloc]initWithFrame: CGRectMake(0, 0, 50, 68)];
//    [cell setRestorationIdentifier:@"GroupDetailCellCollection"];
    
    if (indexPath.row < _contacts.count) {
        Contacts* contact = [[Contacts alloc]init];
        [contact setValuesForKeysWithDictionary:_contacts[indexPath.row]];
        cell.avatar = contact.avatar;
         cell.nickName = contact.nickName;
        cell.groupJid = _groupJid;
        cell.MemJid = contact.jid;
        cell.accountType = contact.accountType;
        if (_isDele && indexPath.row > 0) {
            cell.deleImage.hidden = NO;
            
        }else{
            cell.deleImage.hidden = YES;
           
        }
        
        
    }else if(indexPath.row == _contacts.count){
        cell.nickName = @"";
        cell.addDelect = 0;
        if (_isDele) {
            cell.imageView.hidden = YES;
            cell.userInteractionEnabled = NO;
        }else{
            cell.imageView.hidden = NO;
            cell.userInteractionEnabled = YES;
        }
        cell.deleImage.hidden = YES;
        
    }else if(indexPath.row  == _contacts.count + 1){
        cell.nickName = @"";
        cell.addDelect = 1;
        if (_isDele) {
            cell.imageView.hidden = YES;
            cell.userInteractionEnabled = NO;
        }else{
            cell.imageView.hidden = NO;
             cell.userInteractionEnabled = YES;
        }
        cell.deleImage.hidden = YES;
       
    }
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
        if(indexPath.row  == _contacts.count + 1 && _contacts.count > 1){
            
            
            for(int i = 1; i< _contacts.count; i++){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                GroupDetailCellCollection* cell = (GroupDetailCellCollection*)[collectionView cellForItemAtIndexPath:indexPath];
                cell.deleImage.hidden = !cell.deleImage.hidden;
                _isDele = YES;
            }
            
            
            GroupDetailCellCollection* cell = (GroupDetailCellCollection*)[collectionView cellForItemAtIndexPath:indexPath];
            cell.imageView.hidden = YES;
            cell.userInteractionEnabled = NO;
            
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            cell = (GroupDetailCellCollection*)[collectionView cellForItemAtIndexPath:indexPath];
            cell.imageView.hidden = YES;
            cell.userInteractionEnabled = NO;
        }else if(indexPath.row == _contacts.count){
            [self addLocalGroupMember];
        }else if(indexPath.row < _contacts.count  ){
            GroupDetailCellCollection* cell = (GroupDetailCellCollection*)[collectionView cellForItemAtIndexPath:indexPath];
            if(cell.deleImage.hidden){
                [_delegate groupMemberClicked:cell.MemJid];
            }else{
                [self deleteGroupJid:cell.groupJid membJid:cell.MemJid];
            }
            
        }

}


-(void)collectionViewClick:(UITapGestureRecognizer*) tap{
    
  
    GroupDetailCellCollection* cell = (GroupDetailCellCollection*)[_collectionV cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_contacts.count inSection:0]];
    if(cell.imageView.hidden){
        cell.imageView.hidden = NO;
        cell.userInteractionEnabled = YES;
        if (_isAdmin) {
            cell = (GroupDetailCellCollection*)[_collectionV cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_contacts.count + 1 inSection:0]];
            cell.imageView.hidden = NO;
            cell.userInteractionEnabled = YES;
            
        }
        
        for(int i = 1; i< _contacts.count; i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            GroupDetailCellCollection* cell = (GroupDetailCellCollection*)[_collectionV cellForItemAtIndexPath:indexPath];
            cell.deleImage.hidden = YES;
        }

    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
   // NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]) {
        return NO;
    }
    return  YES;
}


- (void)deleteGroupJid:(NSString*) groupJid membJid:(NSString* )membJid{

    [_hub setLabelText:@"正在删除成员..."];
    [_hub show:YES];
    
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/circle/admin”>
     <circle jid=”” name=””remove=”true”>
     <members>
     <member jid=”” nickname=”” remove=”true”/>
     <member jid=”” nickname=”” role=”” phone=”如果没有开户可以使
     用通讯录中的电话号码”/> </members>
     </circle> </query>
     </iq>
     */
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/circle/admin"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *circle = [NSXMLElement elementWithName:@"circle"];
    NSXMLElement *members = [NSXMLElement elementWithName:@"members"];
    
    [iq addAttributeWithName:@"id" stringValue:IQID_Group_Delete_GroupMember];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"circle.ab-insurance.com"];
    [circle addAttributeWithName:@"jid" stringValue:groupJid];
    
    NSXMLElement *member = [NSXMLElement elementWithName:@"member"];
    [member addAttributeWithName:@"jid" stringValue:membJid];
    [member addAttributeWithName:@"remove" stringValue:@"true"];
    
    [members addChild:member];
    [iq addChild:queryElement];
    [queryElement addChild:circle];
    [circle addChild:members];
    
    //NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
    _membJid= membJid;
}

-(void)deleteLocalGroupMember{
    _hub.hidden = YES;
    if([_delegate respondsToSelector:@selector(groupDetailCellContact:deleMemberSuccess:)]){
        [_delegate groupDetailCellContact:self deleMemberSuccess:_membJid];
    }
}


-(void)addLocalGroupMember{
    
    if([_delegate respondsToSelector:@selector(groupDetailCellContact:addMemberSuccess:)]){
        [_delegate groupDetailCellContact:self addMemberSuccess:nil];
    }

}


@end
