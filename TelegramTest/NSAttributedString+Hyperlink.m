#import "NSAttributedString+Hyperlink.h"



@implementation NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
	NSRange range = NSMakeRange(0, [attrString length]);
	
    
    [attrString addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
    
	[attrString endEditing];
 	
	return attrString;
}

-(void)fixEmoji {
    
    
    static NSDictionary *associations;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        associations = @{@"✌":@"✌️",@"☺":@"☺️",@"☝":@"☝️",@"1⃣":@"1️⃣",@"2⃣":@"2️⃣",@"3⃣":@"3️⃣",@"4⃣":@"4️⃣",@"5⃣":@"5️⃣",@"6⃣":@"6️⃣",@"7⃣":@"7️⃣",@"8⃣":@"8️⃣",@"9⃣":@"9️⃣",@"0⃣":@"0️⃣",@"❤":@"❤️"};
    });
    
    @try {
        [associations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSRange range;
            while ((range = [self.string rangeOfString:key]).location != NSNotFound) {
                [self replaceCharactersInRange:range withString:obj];
            }
        }];
        
        
//        NSArray *badCoreTextSymbols = @[@"ऀ"];
//        
//        [badCoreTextSymbols enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSRange range;
//            while ((range = [self.string rangeOfString:obj]).location != NSNotFound) {
//                [self replaceCharactersInRange:range withString:@"?"];
//            }
//        }];
    } @catch (NSException *exception) {
        
    }
    
    
}

-(NSArray *)detectAndAddLinks:(URLFindType)urlType {
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    NSArray *linkLocations = [NSString textCheckingResultsForText:self.string highlightMentionsAndTags:urlType & URLFindTypeMentions highlightCommands:urlType & URLFindTypeBotCommands];// [[self string] locationsOfLinks:urlType];
    
    [self beginEditing];
    for( NSValue *link in linkLocations ) {
        NSRange range = [link rangeValue];
        
        if(range.location != NSNotFound) {
            
            NSString *sublink = [self.string substringWithRange:range];
            
            [self addAttribute:NSLinkAttributeName value:sublink range:range];
            [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
            [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
            [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
            
            
            if(![sublink hasPrefix:@"@"] && ![sublink hasPrefix:@"#"] && ![sublink hasPrefix:@"/"]) {
                [urls addObject:sublink];
            }
        }
    }
    [self endEditing];
    
    return urls;
    
}


-(void)detectBoldColorInStringWithFont:(NSFont *)font  {
    [self detectBoldColorInStringWithFont:font string:[self.string copy]];
}

-(void)detectBoldColorInStringWithFont:(NSFont *)font string:(NSString *)string {
    NSRange range;
    
    NSUInteger offset = 0;

    while ((range = [string rangeOfString:@"**" options:0 range:NSMakeRange(offset, string.length - offset)]).location != NSNotFound) {
        
        
        
        offset = range.location + range.length;
        
        
        range = [string rangeOfString:@"**" options:0 range:NSMakeRange(offset, string.length - offset)];
        
        if(range.location != NSNotFound) {
            [self addAttribute:NSFontAttributeName value:font range:NSMakeRange(offset, range.location - offset)];
            
            offset+= (range.location - offset) + range.length;
            
        }
        
        
    }
    
    while ((range = [self.string rangeOfString:@"**"]).location != NSNotFound) {
        [self replaceCharactersInRange:range withString:@""];
    }
    
    

    
}


@end