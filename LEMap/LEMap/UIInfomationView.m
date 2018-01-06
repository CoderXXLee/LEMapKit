//
//  UIInfomationView.m
//  CreditAddressBook
//
//  Created by LEE on 15/6/23.
//  Copyright (c) 2015年 LEE. All rights reserved.
//

#import "UIInfomationView.h"
#import <UIKit/UIKit.h>

@interface UIInfomationView () <UIActionSheetDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) NSMapTable *mapTable;

@end

@implementation UIInfomationView

#pragma mark - LazyLoad

- (NSMapTable *)mapTable {
    if (!_mapTable) {
        _mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn];;
    }
    return _mapTable;
}

#pragma mark - Super
#pragma mark - Init

/**
 初始化
 */
+ (instancetype)shared {
    static UIInfomationView *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [UIInfomationView new];
    });
    return info;
}

#pragma mark - PublicMethod

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSArray *)otherButtons
                           clickAtIndex:(ClickAtIndexBlock)clickAtIndex {
    return [[UIInfomationView shared] showAlertViewWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons clickAtIndex:clickAtIndex];
}

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSArray *)otherButtons
                                  style:(UIAlertViewStyle)style
                           keyboardType:(UIKeyboardType)keyboardType
                           clickAtIndex:(AlertViewBlock)clickAtIndex {
    return [[UIInfomationView shared] showAlertViewWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons style:style keyboardType:keyboardType clickAtIndex:clickAtIndex];
}

+ (UIActionSheet *)showActionSheetInView:(UIView *)view
                               WithTitle:(NSString *)title
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                  destructiveButtonTitle:(NSString *)destructiveButton
                       otherButtonTitles:(NSArray *)otherButtons
                            clickAtIndex:(ClickAtIndexBlock)clickAtIndex {
    return [[UIInfomationView shared] showActionSheetInView:view withTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButton otherButtonTitles:otherButtons clickAtIndex:clickAtIndex];
}

#pragma mark - PrivateMethod

- (UIAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];

    [self.mapTable setObject:@[@0, clickAtIndex] forKey:alert];

    for(NSString *buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
    }

    //    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:15]constrainedToSize:CGSizeMake(220,300) lineBreakMode:NSLineBreakByTruncatingTail];
    //
    //    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 220, size.height)];
    //    textLabel.font = [UIFont systemFontOfSize:14];
    //    textLabel.textColor = [UIColor blackColor];
    //    textLabel.backgroundColor = [UIColor clearColor];
    //    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
    //    textLabel.numberOfLines =0;
    //    textLabel.textAlignment =NSTextAlignmentLeft;
    //    textLabel.text = message;
    //    [alert setValue:textLabel forKey:@"accessoryView"];
    //    alert.message =@"";

    [alert show];
    return alert;
}

- (UIAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons style:(UIAlertViewStyle)style keyboardType:(UIKeyboardType)keyboardType clickAtIndex:(AlertViewBlock)clickAtIndex {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];

    [self.mapTable setObject:@[@1, clickAtIndex] forKey:alert];

    alert.alertViewStyle = style;
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.keyboardType = keyboardType;
    for(NSString *buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
    return alert;
}

- (UIActionSheet *)showActionSheetInView:(UIView *)view withTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButton otherButtonTitles:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex {

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                         destructiveButtonTitle:destructiveButton
                                              otherButtonTitles:nil];

    [self.mapTable setObject:clickAtIndex forKey:sheet];

    for(NSString *buttonTitle in otherButtons) {
        [sheet addButtonWithTitle:buttonTitle];
    }

    [sheet showInView:view];
    return sheet;
}



#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate

#pragma mark - alertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSArray *blockType = [self.mapTable objectForKey:alertView];
    if ([blockType.firstObject boolValue]) {
        AlertViewBlock block = blockType.lastObject;
        if (block) block(alertView, buttonIndex);
    } else {
        ClickAtIndexBlock block = blockType.lastObject;
        if (block) block(buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.mapTable removeObjectForKey:alertView];
}

#pragma mark - actionSheetView代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ClickAtIndexBlock block = [self.mapTable objectForKey:actionSheet];
    if (block) block(buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.mapTable removeObjectForKey:actionSheet];
}

/**======================UIAlertController===============================*/

+ (UIAlertController *)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex {
    return [self showAlertControllerWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons destructiveButtonTitle:nil preferredStyle:UIAlertControllerStyleAlert clickAtIndex:clickAtIndex];
}

+ (UIAlertController *)showActionSheetControllerWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons destructiveButtonTitle:(NSString*)destructiveButtonTitle clickAtIndex:(ClickAtIndexBlock)clickAtIndex {
    return [self showAlertControllerWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons destructiveButtonTitle:destructiveButtonTitle preferredStyle:UIAlertControllerStyleAlert clickAtIndex:clickAtIndex];
}

+ (UIAlertController *)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons destructiveButtonTitle:(NSString *)destructiveButtonTitle preferredStyle:(UIAlertControllerStyle)alertStyle clickAtIndex:(ClickAtIndexBlock)clickAtIndex {

    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:3];

    if (cancelButtonTitle) {
        [argsArray addObject:cancelButtonTitle];
    }
    if (destructiveButtonTitle) {
        [argsArray addObject:destructiveButtonTitle];
    }
    [argsArray addObjectsFromArray:otherButtons];

    if ( [self isIosVersion8AndAfter]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:alertStyle];
        for (int i = 0; i < [argsArray count]; i++) {
            UIAlertActionStyle style = UIAlertActionStyleDefault;
            if (0==i && cancelButtonTitle) {
                style = UIAlertActionStyleCancel;
            } else if (0==i && destructiveButtonTitle) {
                style = UIAlertActionStyleDestructive;
            }
            if (1==i && destructiveButtonTitle && cancelButtonTitle) {
                style = UIAlertActionStyleDestructive;
            }

            UIAlertAction *action = [UIAlertAction actionWithTitle:[argsArray objectAtIndex:i] style:style handler:^(UIAlertAction *action) {
                if (clickAtIndex) {
                    clickAtIndex(i);
                }
            }];
            [alertController addAction:action];
        }
        [[self getPresentedViewController] presentViewController:alertController animated:YES completion:nil];
        return alertController;
    }
    return nil;
}

+ (BOOL)isIosVersion8AndAfter {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ;
}

/**
 获取当前屏幕显示的viewcontroller
 */
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;

    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }

    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}

+ (UIViewController *)getPresentedViewController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
