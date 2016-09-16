//
//  EncryptedPoblemViewController.m
//  anbang_ios
//
//  Created by seeko on 14-3-31.
//  update by silencesky on 14-07-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//
//  密保设置

#import "EncryptedPoblemViewController.h"

#import "SelectionCell.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"

#import "DejalActivityView.h"
@interface EncryptedPoblemViewController ()
{
    //TableViewWithBlock *tb;
    //TableViewWithBlock *tb1;
    //UIButton *openButton;
    // UIButton *openButton1;
    // UITextField *question1;
    // UITextField *question2;
    UITextField *answer1;
    UITextField *answer2;
    UITextField *answer3;
    BOOL isOpened;
    
    NSString *questionStr1;
    NSString *questionStr2;
    
    int questionFlag;
}
@end

@implementation EncryptedPoblemViewController
@synthesize tableView = _tableView;


-(void)dealloc{
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setQusetionSuccess) name:@"setQuestion_ok" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [DejalBezelActivityView removeViewAnimated:YES];
    //密保设置
    self.title = NSLocalizedString(@"securityQuestion.question1",@"title");
    
    // Do any additional setup after loading the view from its nib.
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KCurrWidth, KCurrHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    //[_tableView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
    [self setExtraCellLineHidden:_tableView];
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    //        [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    //    }
    
    //确定
    UIBarButtonItem *barBnt=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"public.nav.ok",@"action") style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestions)];
    [self.navigationItem setRightBarButtonItem:barBnt];
    
    //您父亲的姓名是?
    questionStr1 = NSLocalizedString(@"securityQuestion.question1",@"title");
    //您母亲的姓名是?
    questionStr2 = NSLocalizedString(@"securityQuestion.question2",@"title");
    
}


/*
 -(void)ui{
 int height;
 if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
 height=64;
 }else{
 height=0;
 }
 UIBarButtonItem *barBnt=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestions)];
 [self.navigationItem setRightBarButtonItem:barBnt];
 [barBnt release];
 //
 UIButton *btnque1=[UIButton buttonWithType:UIButtonTypeCustom];
 btnque1.frame=CGRectMake(10, height+15, 300, 85);
 [btnque1.layer setMasksToBounds:YES];
 [btnque1.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
 [btnque1.layer setBorderWidth:1.0]; //边框宽度
 [self.view addSubview:btnque1];
 question1=[[UITextField alloc]initWithFrame:CGRectMake(20, height+22, 280, 30)];
 question1.text=@"您母亲的姓名是?";
 question1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
 [question1 setEnabled:NO];
 [self.view addSubview:question1];
 answer1=[[UITextField alloc]initWithFrame:CGRectMake(20, height+50, 280, 30)];
 answer1.placeholder=@"请输入答案";
 answer1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
 [answer1 setBorderStyle:UITextBorderStyleRoundedRect];
 answer1.delegate=self;
 [self.view addSubview:answer1];
 
 UIButton *btnque2=[UIButton buttonWithType:UIButtonTypeCustom];
 btnque2.frame=CGRectMake(10, height+105, 300, 85);
 [btnque2.layer setMasksToBounds:YES];
 [btnque2.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
 [btnque2.layer setBorderWidth:1.0]; //边框宽度
 [self.view addSubview:btnque2];
 question2=[[UITextField alloc]initWithFrame:CGRectMake(20, height+110, 280, 30)];
 question2.text=@"您母亲的姓名是?";
 question2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
 [question2 setEnabled:NO];
 [self.view addSubview:question2];
 answer2=[[UITextField alloc]initWithFrame:CGRectMake(20, height+140, 280, 30)];
 answer2.placeholder=@"请输入答案";
 answer2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
 [answer2 setBorderStyle:UITextBorderStyleRoundedRect];
 answer2.delegate=self;
 [self.view addSubview:answer2];
 
 //选择下拉菜单
 [tb.layer setBorderColor:[UIColor lightGrayColor].CGColor];
 [tb.layer setBorderWidth:2];
 tb=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(20, height+50, 240, 0)];
 [self.view addSubview:tb];
 
 openButton=[[UIButton alloc]initWithFrame:CGRectMake(240, height+20, 30, 30)];
 [openButton setBackgroundImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
 [openButton addTarget:self action:@selector(changeOpenStatus) forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:openButton];
 [openButton release];
 [tb initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
 section=4;
 return section;
 
 } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
 SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
 if (!cell) {
 cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
 [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
 }
 switch ([indexPath row]) {
 case 0:
 [cell.lb setText:[NSString stringWithFormat:@"您父亲的姓名是?"]];
 break;
 case 1:
 [cell.lb setText:[NSString stringWithFormat:@"您母亲的姓名是?"]];
 break;
 case 2:
 [cell.lb setText:[NSString stringWithFormat:@"您配偶的姓名是?"]];
 break;
 case 3:
 [cell.lb setText:[NSString stringWithFormat:@"您的出生地是?"]];
 break;
 default:
 break;
 }
 //        [cell.lb setText:[NSString stringWithFormat:@"Select %d",indexPath.row]];
 return cell;
 } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
 SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
 question1.text=cell.lb.text;
 [openButton sendActionsForControlEvents:UIControlEventTouchUpInside];
 }setHeightForRowAtIndexPathBlock:^CGFloat( UITableView *tableView,NSIndexPath *indexPath){
 return 40;
 
 }
 ];
 [tb.layer setBorderColor:[UIColor lightGrayColor].CGColor];
 [tb.layer setBorderWidth:2];
 
 tb1=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(20, height+140, 240, 0)];
 [self.view addSubview:tb1];
 
 openButton1=[[UIButton alloc]initWithFrame:CGRectMake(240, height+110, 30, 30)];
 [openButton1 setBackgroundImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
 [openButton1 addTarget:self action:@selector(changeOpenStatus1) forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:openButton1];
 [openButton1 release];
 [tb1 initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
 section=4;
 return section;
 
 } setCellForIndexPathBlock:^(UITableView *tableView1,NSIndexPath *indexPath1){
 SelectionCell *cell=[tableView1 dequeueReusableCellWithIdentifier:@"SelectionCell"];
 if (!cell) {
 cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
 [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
 }
 switch ([indexPath1 row]) {
 case 0:
 [cell.lb setText:[NSString stringWithFormat:@"您父亲的姓名是?"]];
 break;
 case 1:
 [cell.lb setText:[NSString stringWithFormat:@"您母亲的姓名是?"]];
 break;
 case 2:
 [cell.lb setText:[NSString stringWithFormat:@"您配偶的姓名是?"]];
 break;
 case 3:
 [cell.lb setText:[NSString stringWithFormat:@"您的出生地是?"]];
 break;
 default:
 break;
 }
 //        [cell.lb setText:[NSString stringWithFormat:@"Select %d",indexPath.row]];
 return cell;
 } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
 SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
 question2.text=cell.lb.text;
 [openButton1 sendActionsForControlEvents:UIControlEventTouchUpInside];
 }setHeightForRowAtIndexPathBlock:^CGFloat( UITableView *tableView,NSIndexPath *indexPath){
 return 40;
 
 }
 ];
 [tb1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
 [tb1.layer setBorderWidth:2];
 [tb release];
 [tb1 release];
 }
 */


- (void)addQuestionActionSheet
{
    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"securityQuestion.actionSheetTitle",@"title") delegate:self cancelButtonTitle:NSLocalizedString(@"securityQuestion.actionSheetCancel",@"action") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"securityQuestion.question1",@"action"),NSLocalizedString(@"securityQuestion.question2",@"action"),NSLocalizedString(@"securityQuestion.question3",@"action"),NSLocalizedString(@"securityQuestion.question4",@"action"),nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view.window];
    
}

#pragma mark -
#pragma mark xiong actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (questionFlag==0) {
                questionStr1 = NSLocalizedString(@"securityQuestion.question1",@"message");
            }else{
                questionStr2 = NSLocalizedString(@"securityQuestion.question1",@"message");
            }
            [_tableView reloadData];
            break;
        case 1:
            if (questionFlag==0) {
                questionStr1 = NSLocalizedString(@"securityQuestion.question2",@"message");
            }else{
                questionStr2 = NSLocalizedString(@"securityQuestion.question2",@"message");
            }
            [_tableView reloadData];
            break;
        case 2:
            if (questionFlag==0) {
                questionStr1 = NSLocalizedString(@"securityQuestion.question3",@"message");
            }else{
                questionStr2 = NSLocalizedString(@"securityQuestion.question3",@"message");
            }
            [_tableView reloadData];
            break;
        case 3:
            if (questionFlag==0) {
                questionStr1 = NSLocalizedString(@"securityQuestion.question4",@"message");
            }else{
                questionStr2 = NSLocalizedString(@"securityQuestion.question4",@"message");
            }
            [_tableView reloadData];
            break;
        default:
            
            break;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"setQuestion_ok" object:nil];
}



- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([cell viewWithTag:10001]) {
        [[cell viewWithTag:10001] removeFromSuperview];
    }
    
    if (indexPath.row==0) {
        
        cell.textLabel.text = questionStr1;
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.row==1){
        answer1 = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 35)];
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [answer1 setKeyboardType:UIKeyboardTypeDefault];
        answer1.clearButtonMode = UITextFieldViewModeWhileEditing;
        //答案
        [answer1 setPlaceholder:NSLocalizedString(@"securityQuestion.answer",@"title")];
        //设置字体颜色
        answer1.textColor = [UIColor blueColor];
        answer1.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        [answer1 becomeFirstResponder ];
        [cell addSubview:answer1];
        cell.layer.borderWidth = 0;
    }else if(indexPath.row==2){
        cell.textLabel.text = questionStr2;
        // [cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        cell.textLabel.numberOfLines =0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.row==3){
        answer2 = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, 280, 35)];
        //设置边框样式，只有设置了才会显示边框样式
        // text.borderStyle = UITextBorderStyleRoundedRect;
        [answer2 setKeyboardType:UIKeyboardTypeDefault];
        answer2.clearButtonMode = UITextFieldViewModeWhileEditing;
        //答案
        [answer2 setPlaceholder:NSLocalizedString(@"securityQuestion.answer",@"title")];
        //设置字体颜色
        answer2.textColor = [UIColor blueColor];
        answer2.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        [cell addSubview:answer2];
        cell.layer.borderWidth = 0;
    }else if(indexPath.row==4){
        
        //        cell.textLabel.text = quseitonStr3;
        //        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        //        cell.textLabel.textColor = [UIColor lightGrayColor];
        //        cell.textLabel.frame = CGRectMake(0 , 0, 300, 50);
        //        cell.textLabel.numberOfLines =0;
        //        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        
    }else if(indexPath.row==5){
        
        //        answer3 = [[[UITextField alloc]initWithFrame:CGRectMake(20, 0, 280, 35)]autorelease];
        //         [answer3 setKeyboardType:UIKeyboardTypeDefault];
        //        //设置边框样式，只有设置了才会显示边框样式
        //        // text.borderStyle = UITextBorderStyleRoundedRect;
        //        answer3.clearButtonMode = UITextFieldViewModeWhileEditing;
        //        [answer3 setPlaceholder:@"答案"];
        //        //设置字体颜色
        //        answer3.textColor = [UIColor blueColor];
        //        answer3.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        //        [cell addSubview:answer3];
        //        cell.layer.borderWidth = 0;
        
    }else if(indexPath.row==6){
        //[cell setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:1.6 alpha:1]];
        
    }else if(indexPath.row==7){
        
        
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row==0) {
        questionFlag = 0;
        [self addQuestionActionSheet];
    }else if(indexPath.row==2){
        questionFlag = 1;
        [self addQuestionActionSheet];
    }
    
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 40;
    }else if (indexPath.row==1) {
        return 43;
    }else if(indexPath.row==2){
        return 40;
    }else if(indexPath.row==3){
        return 43;
    }else if(indexPath.row==4){
        return 30;
    }else if(indexPath.row==5){
        return 35;
        
    }else if(indexPath.row==6){
        return 15;
        
    }else{
        return 40;
    }
}



/*
 //点击按钮下拉菜单
 -(void)changeOpenStatus{
 if (isOpened) {
 
 [UIView animateWithDuration:0.3 animations:^{
 UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
 [openButton setImage:closeImage forState:UIControlStateNormal];
 
 CGRect frame=tb.frame;
 
 frame.size.height=0;
 [tb setFrame:frame];
 
 } completion:^(BOOL finished){
 
 isOpened=NO;
 }];
 }else{
 
 
 [UIView animateWithDuration:0.3 animations:^{
 UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
 [openButton setImage:openImage forState:UIControlStateNormal];
 
 CGRect frame=tb.frame;
 
 frame.size.height=120;
 [tb setFrame:frame];
 } completion:^(BOOL finished){
 
 isOpened=YES;
 }];
 
 
 }
 
 }
 //点击按钮下拉菜单
 -(void)changeOpenStatus1{
 if (isOpened) {
 
 [UIView animateWithDuration:0.3 animations:^{
 UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
 [openButton1 setImage:closeImage forState:UIControlStateNormal];
 
 CGRect frame=tb1.frame;
 
 frame.size.height=0;
 [tb1 setFrame:frame];
 
 } completion:^(BOOL finished){
 isOpened=NO;
 }];
 }else{
 
 
 [UIView animateWithDuration:0.3 animations:^{
 UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
 [openButton1 setImage:openImage forState:UIControlStateNormal];
 
 CGRect frame=tb1.frame;
 
 frame.size.height=120;
 [tb1 setFrame:frame];
 } completion:^(BOOL finished){
 
 isOpened=YES;
 }];
 
 
 }
 
 }
 */



-(void)sendQuestions{
    /*
     <iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/tips”>
     <tip>
     <question></question>
     <answer></answer> </tip>
     <tip>
     <question></question>
     <answer></answer> </tip>
     </query> </iq>
     
     <iq type=”get”>
     <query xmlns=”http://www.nihualao.com/xmpp/tips”/>
     </iq>
     */
    if (answer1.text.length<1||answer2.text.length<1) {
        //请输入答案
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title")  message:NSLocalizedString(@"securityQuestion.inputAnswer",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title")  otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/tips"];
        NSXMLElement *tip1=[NSXMLElement elementWithName:@"tip"];
        NSXMLElement *tip2=[NSXMLElement elementWithName:@"tip"];
        
        NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
        NSXMLElement *quseiton11=[NSXMLElement elementWithName:@"question" stringValue:questionStr1];
        NSXMLElement *quseiton22=[NSXMLElement elementWithName:@"question" stringValue:questionStr2];
        NSXMLElement *answer11=[NSXMLElement elementWithName:@"answer" stringValue:answer1.text];
        NSXMLElement *answer22=[NSXMLElement elementWithName:@"answer" stringValue:answer2.text];
        
        [iq addAttributeWithName:@"id" stringValue:@"sendQuestion"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [tip1 addChild:quseiton11];
        [tip1 addChild:answer11];
        [tip2 addChild:quseiton22];
        [tip2 addChild:answer22];
        
        [queryElement addChild:tip1];
        [queryElement addChild:tip2];
        
        [iq addChild:queryElement];
        //    NSLog(@"%@",question1.text);
        //   NSLog(@"%@",iq);
        [[XMPPServer xmppStream] sendElement:iq];
        [DejalBezelActivityView activityViewForView:self.view];
    }
}

-(void)setQusetionSuccess{
    
    [DejalBezelActivityView removeViewAnimated:YES];
    //设置成功
    UIAlertView *alectView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"public.alert.prompt",@"title") message:NSLocalizedString(@"securityQuestion.success",@"message") delegate:self cancelButtonTitle:NSLocalizedString(@"public.alert.ok",@"title") otherButtonTitles:nil, nil];
    alectView.tag=2000;
    [alectView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2000) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)backgroundTop:(id)sender{
    [answer1 resignFirstResponder];
    [answer2 resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;{
    return [textField resignFirstResponder];
}

@end
