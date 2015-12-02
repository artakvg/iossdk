#define THROW_CANT_CREATE_INSTANCE 	@throw [NSException exceptionWithName:@"Can't create instance" reason:@"Default constructor must not be used" userInfo:nil]
#define THROW_MUST_OVERRIDE_METHOD 	@throw [NSException exceptionWithName:@"Can't send a message" reason:@"Child classes must override this virtual message" userInfo:nil]

#define FORMAT(X, Y) [NSString stringWithFormat:X, Y, nil]
#define FORMAT2(X, Y, Z) [NSString stringWithFormat:X, Y, Z, nil]

