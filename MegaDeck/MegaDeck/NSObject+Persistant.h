//
//  NSObject+Persistant.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/25/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Persistant)

- (void) serialize;
- (void) unserialize;

@end
