# Pico-Kit :triangular_ruler:

A collection of helpers to make your life easier. Comes with four libraries:
* oop
	* `oop.class(properties?, parents?, constructor?, metatable?) -> table`

		A multi-purpose class creator that returns a table that can be called with a table of properties to generate class instances. The class's constructor is automatically generated and does the following for every parent and then current instance:
		* checks that all required properties are satisfied
		* copies over first the default properties and then the properties passed to the constructor to the instance table
		* calls the provided `constructor` argument (if it exists)

		Detailed explanation of arguments:
		* `properties`: A table of property keys/values that will be copied down to every instances. Properties with a value of `"req"` are considered unset and are required to be provided on an instance creation.
		* `parents`: A list of parents. The class's `__index` is set to these parents. Their constructors are also automatically called upon an instance creation.
		* `constructor`: A function called at the end of instance creation.
		* `metatable`: A metatable passed to every instance.

* tools
	* `tools.assign(table, initial={}) -> table`

		Similar to javascript's `Object.assign`: copies over a table to an empty table, or, if provided, an existing table.

	* `tools.assigndeep(table, initial={}) -> table`

		Similar to `tools.assign` but it iterates through tables, effectively performing a deep copy.

* debug
	* `debug.tstr(table, indent?) -> str`

		Converts a table to a string, optionally indenting each line with `indent` number of spaces.

	* `debug.print(...)`

		Prints values to the console with `printh`. If it encounters nil it prints `nil`, and if it encounters a table it uses `debug.tstr` to print out the entire table. Very useful for debugging because not only can you print multiple values at once, but `tstr` allows you to see the entire contents of even a nested table.

* physics
	* `physics.collided(body1, body2) -> bool`

		Returns whether two bodies intersect.

	* `physics.world(parameters) -> world`


		* properties

			*	`bodies={}`

			* `gravity={0, .5}` a vector that is applied with `body.shove` to every body during `world.update`, taking into consideration each bodies' `weight` and `mass`

		* `physics.world:update()`

			For each non-static body: applies gravity, friction, checks for collisions and then updates the position. Call this every frame.

		* `physics.world:addbody(body) -> body`

			Adds a body to the world and returns it.

	* `physics.body(parameters) -> body`

		A single physics body.

		* properties
			* `pos="req"`
			* `size="req"`
			* `vel={0, 0}`
			* `mass={1, 1}` proportionally affects all `body.shove` and `body.slow` calls
			* `weight={1, 1}` proportionally affects all gravity applied to the body
			* `friction={.1, 0}` applied with `body.slow` every `world.update` call, proportionally affects velocity
			* `collisions={}` a list of object collisions, reset during `world.update` call
			* `static=false` a static object that is ignored during `world.update`
			* `layer=0x1` a binary field that represents collision layers. Every `world.update` calls a `band` operation between two bodies' `layer` properties determines whether they will be checked for a collision.

		* `physics.body:update()`

			Adds the current velocity to the position.

		* `physics.body:shove(vector)`

			For x and y, adds the vector multiplied by `body.mass` to the current velocity.

		* `physics.body:slow(vector)`

			For x and y, subtracts the vector multiplied by `body.mass` from the current velocity. If the result of this operation crosses 0, the velocity on the corresponding axis is set to 0.

		* `physics.body:checkcollided(body)`

			For x and y, checks if the current body and provided body would have collided with that axis of the body's velocity, and if so:

			 * Adds the provided body to `body.collisions`.
			 * Adjusts the body's position on that axis to the edge of the provided object.
			 * Sets that axis of the body's velocity to 0.

## Setting up
To use this library, just download the `starter.p8` file and open it in Pico. Check out `example.p8` for a little example game.

## Contributing
Suggested edits are welcome! Just create a pull request and make sure to edit both the starter and example files.
