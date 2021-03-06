#import <Cedar/Cedar.h>
#import "KSPromise.h"
#import "KSDeferred.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(KSPromiseSpec)

describe(@"KSPromise", ^{

    __block KSDeferred *deferred;
    __block KSPromise<NSString *> *promise;
    
    beforeEach(^{
        deferred = [KSDeferred defer];
        promise = deferred.promise;
    });
    
    describe(@"then:", ^{
        describe(@"for fulfilled promises", ^{
            beforeEach(^{
                [deferred resolveWithValue:@"A"];
            });
            
            it(@"must return a new promise", ^{
                KSPromise<NSString *> *thenPromise = [promise then:nil];
                
                thenPromise should_not be_same_instance_as(promise);
            });
            
            it(@"calls the fulfillment callback", ^{
                __block BOOL done = NO;
                [promise then:^NSString*(NSString *value) {
                    value should equal(@"A");
                    done = YES;
                    return value;
                }];
                done should equal(YES);
            });
        });
        
        describe(@"for rejected promises", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Broken" code:1 userInfo:nil];
                
                [deferred rejectWithError:error];
            });

            it(@"rejects the returned promise with the original error", ^{
                KSPromise *nextPromise = [promise then:nil];
                nextPromise.error should equal(error);
            });
        });
    });
});

SPEC_END
