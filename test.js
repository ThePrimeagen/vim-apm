
async function foo() {
}

async function bar() {
}

process.on('unhandledRejection', (reason, promise) => {

});

/** @type {Promise<number | null>} */
async function main() {
    /** @type {number | undefined} */
    let fooVal = undefined;
    try {
        fooVal = await foo();
    } catch (e) {
        // some special error handling
        return null
    }

    /** @type {number | undefined} */
    let barVal = undefined;
    try {
        barVal = await bar();
    } catch (e) {
        // some special error handling
        return null
    }

    return barVal + fooVal
}

func thing() (error, int) {
    fooVal, err := foo();
    if err != nil {
        // some special error handling
        return err
    }
    barVal, err = bar();
    if err != nil {
        // some special error handling
        return err
    }

    return nil, barVal + fooVal
}
