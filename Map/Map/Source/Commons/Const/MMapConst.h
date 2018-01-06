//
//  MMapConst.h
//  Map
//
//  Created by mac on 2018/1/6.
//

#ifndef MMapConst_h
#define MMapConst_h

#ifdef DEBUG
#define LELog(...) NSLog(__VA_ARGS__)
#else
#define LELog(...)
#endif

#define LEError(m, c) [NSError errorWithDomain:@"jsonFailMsg" code:c userInfo:@{@"message":m}]

//定义颜色函数
#define LEColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#endif /* MMapConst_h */
