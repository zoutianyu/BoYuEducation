//
//  ZYViewController.m
//  BoYuEducation
//
//  Created by Wei on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZYViewController.h"

@interface ZYViewController ()

@end

@implementation ZYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load example view, frame: %@", NSStringFromCGRect(self.view.frame));
    _skinId = 0;
    
    UIView *logoView = [[UIView alloc]initWithFrame:CGRectMake(25, 15, 164, 60)];
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    logoView.backgroundColor = [UIColor colorWithPatternImage:logoImage];
    [self.view addSubview:logoView];
    [logoView release];
    
    [self changeSkinId:_skinId];
    
    _menuView = [[ZYMenuView alloc]init];
    _menuView.delegate = self;
    [self.view addSubview:_menuView];
    
    [self initBackView];
    //初始化centerView
    _centerView = [[ZYCenterView alloc]initWithMenuCellIndex:0];
    //添加拖动手势
    [_centerView addPanGesture];
    _centerView.delegate = self;
    [self.view addSubview:_centerView];
    
    return;
}

- (void)initRightViewWithView: (UIView *)view
{
    if (_rightViewController == nil) {
        _rightViewController = [[ZYRightViewController alloc]init];
        _rightViewController.delegate = self;
    }
    
//    [_rightViewController putOut];
    
    _rightViewController.putInFrame = view.frame;
    _rightViewController.view = view;
    
    [_rightViewController.view setFrame:CGRectMake(1524, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    [_rightViewController addPanGesture];
    [self.view addSubview:_rightViewController.view];
//    [_rightViewController putIn];
}

//初始化backView
- (void)initBackView
{
    _backView = [[UIView alloc]initWithFrame:CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_WIDTH + BY_CENTERVIEW_WIDTH - BY_CENTERVIEW_OVER_LENGHT), 0, (1024 - BY_MENUVIEW_MARGIN_LEFT - BY_MENUCELL_WIDTH - BY_CENTERVIEW_WIDTH + BY_CENTERVIEW_OVER_LENGHT), 748)];
    _backView.exclusiveTouch = YES;
    
    NSMutableArray *appViewsArray = [[NSMutableArray alloc]init];
    
    UIImage *image_1 = [[UIImage imageNamed:@"button_01.png"]autorelease];
    ZYAppView *appView_1 = [[ZYAppView alloc]initWithImage:image_1 Name:@"营销工具"];
    [appViewsArray addObject:appView_1];
    [appView_1 release];
    
    UIImage *image_2 = [[UIImage imageNamed:@"button_02.png"]autorelease];
    ZYAppView *appView_2 = [[ZYAppView alloc]initWithImage:image_2 Name:@"金融产品"];
    [appViewsArray addObject:appView_2];
    [appView_2 release];
    
    UIImage *image_3 = [[UIImage imageNamed:@"button_03.png"]autorelease];
    ZYAppView *appView_3 = [[ZYAppView alloc]initWithImage:image_3 Name:@"计算器"];
    [appViewsArray addObject:appView_3];
    [appView_3 release];
    
    UIImage *image_4 = [[UIImage imageNamed:@"button_04.png"]autorelease];
    ZYAppView *appView_4 = [[ZYAppView alloc]initWithImage:image_4 Name:@"更换皮肤"];
    [appViewsArray addObject:appView_4];
    [appView_4 release];
    
    UIImage *image_5 = [[UIImage imageNamed:@"button_plus.png"]autorelease];
    ZYAppView *appView_5 = [[ZYAppView alloc]initWithImage:image_5 Name:@""];
    [appViewsArray addObject:appView_5];
    [appView_5 release];
    
    _gridView = [[ZYGridView alloc]initWithZYAppViews:appViewsArray];
    [appViewsArray release];
    _gridView.delegate = self;
    _gridView.exclusiveTouch = YES;
    
    //水平对齐
    CGRect backViewFrame = _backView.frame;
    CGRect gridViewFrame = _gridView.frame;
    gridViewFrame = CGRectMake(((backViewFrame.size.width - gridViewFrame.size.width) / 2), gridViewFrame.origin.y, gridViewFrame.size.width, gridViewFrame.size.height);
    [_gridView setFrame:gridViewFrame];
    
    //向右滑动关闭窗口
    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIView *hintImageView = [[UIView alloc]initWithFrame:CGRectMake(40, 450, closeImage.size.width, closeImage.size.height)];
    hintImageView.backgroundColor = [UIColor colorWithPatternImage:closeImage];
    [_gridView addSubview:hintImageView];
    [hintImageView release];
    
    [_backView addSubview:_gridView];
    [self.view addSubview:_backView];
}

//backView适配动画
- (void)doBackViewAnimationWithRecognizerDirection: (UISwipeGestureRecognizerDirection)recognizerDirection
{
    CGRect centerViewFrame = _centerView.frame;
    CGRect backViewFrame = _backView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (recognizerDirection == UISwipeGestureRecognizerDirectionLeft && _gridView.isInitStatic == YES) {
        backViewFrame = CGRectMake((centerViewFrame.origin.x + centerViewFrame.size.width), backViewFrame.origin.y, backViewFrame.size.width + BY_CENTERVIEW_MOVE_LENGHT, backViewFrame.size.height);
        _gridView.isInitStatic = NO;
    } else if (recognizerDirection == UISwipeGestureRecognizerDirectionRight && _gridView.isInitStatic == NO) {
        backViewFrame = CGRectMake((centerViewFrame.origin.x + centerViewFrame.size.width), backViewFrame.origin.y, backViewFrame.size.width - BY_CENTERVIEW_MOVE_LENGHT, backViewFrame.size.height);
        _gridView.isInitStatic = YES;
    }
    
    [_backView setFrame:backViewFrame];
    [UIView commitAnimations];
    NSLog(@"move backView.");
    
    //水平对齐gridView
    CGRect gridViewFrame = _gridView.frame;
    gridViewFrame = CGRectMake(((backViewFrame.size.width - gridViewFrame.size.width) / 2), gridViewFrame.origin.y, gridViewFrame.size.width, gridViewFrame.size.height);
    
    //动画开始
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [_gridView setFrame:gridViewFrame];
    [UIView commitAnimations];
    
}

- (void)didMoveCenterViewToDirection:(NSString *)direction
{
    if ([direction isEqualToString:@"left"]) {
        [self doBackViewAnimationWithRecognizerDirection:UISwipeGestureRecognizerDirectionLeft];
    } else {
        [self doBackViewAnimationWithRecognizerDirection:UISwipeGestureRecognizerDirectionRight];
    }
}

- (void)centerTableView:(ZYCenterTableView *)centerTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ZYView press button section:%d, row:%d", indexPath.section, indexPath.row);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 300, 300, 100)];
    
    switch (_menuView.currentCellIndex) {
        case 0:
        {
            label.text = [NSString stringWithFormat:@"菜单1 group：%d row:%d", indexPath.section, indexPath.row];
        }
            break;
            
        case 1:
        {
            label.text = [NSString stringWithFormat:@"菜单2 group：%d row:%d", indexPath.section, indexPath.row];
        }
            break;
            
        case 2:
        {
            label.text = [NSString stringWithFormat:@"菜单3 group：%d row:%d", indexPath.section, indexPath.row];
        }
            break;
            
        default:
            break;
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_MARGIN_LEFT + BY_MENUCELL_WIDTH - BY_CENTERVIEW_OVER_LENGHT - BY_CENTERVIEW_MOVE_LENGHT + BY_CENTERVIEW_WIDTH - 10), 0, 470, 748)];
    view.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:label];
    [label release];
    if (!(_rightViewController == nil)) {
        [_rightViewController putOutWithChecking:NO];
    }
    [self initRightViewWithView:view];
    [_rightViewController putIn];
    [view release];
}

- (void)ZYRightViewPutIn
{
    _centerView.isLocked = YES;
}

- (void)ZYRightViewPutOut
{
    _centerView.isLocked = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (index == 0) {
        [_cellTabViews addObject:[[UIView alloc]init]];
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_cellContents objectAtIndex:index];
    
    CGRect frame;
    NSString *titleImageName;
    
    if (_cellTabViews.count < _cellContents.count) {
        frame = CGRectMake(0, (BY_MENUCELL_HEIGHT * (index - 1)), BY_MENUCELL_TAB_WIDTH, BY_MENUCELL_TAB_HEIGHT);
        UIView *tabView = [[UIView alloc]initWithFrame:frame];
        titleImageName = [[NSString alloc]initWithFormat:@"title_%da.png", index];
        tabView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:titleImageName]];
        
        [_cellTabViews addObject:tabView];
        [_menuView addSubview:tabView];
        
        [tabView release];
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BY_MENUCELL_WIDTH, BY_MENUCELL_HEIGHT)];
    titleImageName = [NSString stringWithFormat:@"title_%db.png", index];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:titleImageName]];
//    NSLog(@"titleImageName:%@", titleImageName);
    [cell addSubview:view];
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return BY_MENUCELL_TAB_HEIGHT;
    }
    return BY_MENUCELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellContents.count;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return nil;
    }
    NSLog(@"will Select Row %d", [tableView indexPathForSelectedRow].row);
    if ([tableView indexPathForSelectedRow].row == indexPath.row) {
        NSLog(@"This row is selecting.");
        return indexPath;
    }
    NSLog(@"selected row %d.", indexPath.row);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.frame = CGRectMake(0, 0, (BY_MENUCELL_WIDTH + BY_MENUCELL_MOVE_LENGHT), BY_MENUCELL_HEIGHT);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    CGRect frame;
    
    frame = cell.frame;
    frame.origin.x -= BY_MENUCELL_MOVE_LENGHT;
    [cell setFrame:frame];
    
    UIView *cellTabView = (UIView *)[_cellTabViews objectAtIndex:indexPath.row];
    frame = cellTabView.frame;
    frame.origin.x -= BY_MENUCELL_MOVE_LENGHT;
    [cellTabView setFrame:frame];
    [UIView commitAnimations];
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselected row %d.", indexPath.row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    CGRect frame = cell.frame;
    frame.origin.x += BY_MENUCELL_MOVE_LENGHT;
    [cell setFrame:frame];
    
    UIView *cellTabView = (UIView *)[_cellTabViews objectAtIndex:indexPath.row];
    CGRect cellTabFrame = cellTabView.frame;
    cellTabFrame.origin.x += BY_MENUCELL_MOVE_LENGHT;
    [cellTabView setFrame:cellTabFrame];
    
    [UIView commitAnimations];
}

//ZYAppView代理
- (void)pressButton:(NSString *)buttonName
{
    NSLog(@"press button %@", buttonName);
    if ([buttonName isEqualToString:@"更换皮肤"]) {
        [self changeSkinId:++_skinId];
    }
}

//更换皮肤
- (void)changeSkinId: (NSInteger)skinId
{
    NSArray *skinNameArray = [[NSArray alloc]initWithObjects:
                              @"background_01.png", 
                              @"background_02.png", 
                              @"background_03.png", 
                              @"background_04.png", 
                              @"background_05.png", nil];
    
    // 准备动画
    CATransition *animation = [CATransition animation];
    //动画播放持续时间
    [animation setDuration:0.5f];
    //动画速度,何时快、慢
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation setType:kCATransitionFade];
    [self.view.layer addAnimation:animation forKey:nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[skinNameArray objectAtIndex:(skinId % skinNameArray.count)]]];
    // 结束动画
    [UIView commitAnimations];
}

//menuView代理
- (void)didSelectMenuCellAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"00000000000000");
        }
            break;
            
        case 1:
        {
            NSLog(@"11111111111111");
        }
            break;
            
        case 2:
        {
            NSLog(@"22222222222222");
        }
            break;
            
        default:
            break;
    }
    
    //切换centerView内容
    [_centerView changeContentViewWithMenuIndex:index];
    [_rightViewController putOutWithChecking:NO]; 
}

- (void)ZYMenuView:(UIView *)menuView PressSetupButton:(UIButton *)setupButton
{
    _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 748)];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.6f;
    [self.view addSubview:_maskView];
    
    UIView *setupView = [[UIView alloc]initWithFrame:CGRectMake(300, 748, 450, 400)];
    setupView.backgroundColor = [UIColor greenColor];
    
    UIButton *closeButton;
    closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton setFrame:CGRectMake(100, 100, 200, 50)];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(pressSetupCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [setupView addSubview:closeButton];
    
    // 准备动画
    CATransition *animation = [CATransition animation];
    //动画播放持续时间
    [animation setDuration:0.3f];
    //动画速度,何时快、慢
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    /*动画效果
     kCATransitionFade      淡出
     kCATransitionMoveIn    覆盖原图
     kCATransitionPush      推出
     kCATransitionReveal    底部显出来
     */
    [animation setType:kCATransitionFade];
    [self.view.layer addAnimation:animation forKey:nil];
    
    //变更
    [self.view addSubview:setupView];
    
    //结束动画
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [setupView setFrame:CGRectMake(300, 150, 450, 400)];
    [UIView commitAnimations];
    
    [setupView release];
    
    return;
}

- (void)pressSetupCloseButton:sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"close!!!");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [button.superview setFrame:CGRectMake(300, 748, 450, 400)];
    [UIView commitAnimations];
    
    // 准备动画
    CATransition *animation = [CATransition animation];
    //动画播放持续时间
    [animation setDuration:0.3f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation setType:kCATransitionFade];
    [self.view.layer addAnimation:animation forKey:nil];
    //变更
    [_maskView removeFromSuperview];
    // 结束动画
    [UIView commitAnimations];
    
    [_maskView release];
}

- (void)pressSetupButton:sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview.superview.superview removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [_menuView release];
    [_menuView dealloc];
    [_cellContents release];
//    [_cellContents dealloc];
    [_cellTabViews release];
//    [_cellTabViews dealloc];
    [_centerView release];
    [_centerView dealloc];
    [_backView release];
//    [_backView dealloc];
    [_gridView release];
//    [_gridView dealloc];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
