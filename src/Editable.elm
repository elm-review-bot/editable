module Editable
    exposing
        ( Editable(Editable, ReadOnly)
        , cancel
        , edit
        , map
        , save
        , update
        , value
        , isDirty
        , isDirtyWith
        )

{-| Editable represents a value that can be read-only or editable.
`ReadOnly a` holds the locked value and `Editable a a` holds both the old and the newly modified value.

@docs Editable, cancel, edit, map, save, update, value, isDirty, isDirtyWith

-}


{-| An `Editable` value is either `ReadOnly` or `Editable`.

    view : Editable String -> Html msg
    view editable =
        case editable of
            Editable saved modified ->
                input [ defaultValue modified ] []

            ReadOnly saved ->
                text saved

-}
type Editable a
    = Editable a a
    | ReadOnly a


{-| Makes a `ReadOnly` value `Editable`.

    Editable.ReadOnly "old"
        |> Editable.update "new" --> ReadOnly "old"
        |> Editable.edit         --> Editable "old" "old"
        |> Editable.update "new" --> Editable "old" "new"

-}
edit : Editable a -> Editable a
edit x =
    case x of
        Editable _ _ ->
            x

        ReadOnly value ->
            Editable value value


{-| Apply a function to an `Editable`.

    Editable.ReadOnly "old"
        |> Editable.map String.toUpper --> ReadOnly "old"

    Editable.Editable "old" "old"
        |> Editable.map String.toUpper --> Editable "old" "OLD"

-}
map : (a -> a) -> Editable a -> Editable a
map f x =
    case x of
        Editable saved modified ->
            Editable saved (f modified)

        ReadOnly saved ->
            ReadOnly saved


{-| Updates an `Editable` and doesn't change a `ReadOnly`.

    Editable.ReadOnly "old"
        |> Editable.update "new"  --> ReadOnly "old"

    Editable.Editable "old" "old"
        |> Editable.update "new"  --> Editable "old" "new"

-}
update : a -> Editable a -> Editable a
update value =
    map (always value)


{-| Save a modified value. This puts the modified value into the context of `ReadOnly`.

    Editable.Editable "old" "new"
        |> Editable.save          --> ReadOnly "new"

    Editable.ReadOnly "old"
        |> Editable.edit          --> Editable "old" "old"
        |> Editable.update "new"  --> Editable "old" "new"
        |> Editable.save          --> ReadOnly "new"

-}
save : Editable a -> Editable a
save x =
    case x of
        Editable _ modified ->
            ReadOnly modified

        ReadOnly _ ->
            x


{-| Cancels a modified value. This puts the old value into the context of `ReadOnly`.

    Editable.Editable "old" "new"
        |> Editable.cancel       --> ReadOnly "old"

-}
cancel : Editable a -> Editable a
cancel x =
    case x of
        Editable value _ ->
            ReadOnly value

        ReadOnly _ ->
            x


{-| Returns the current value of an Editable.

    Editable.ReadOnly "old"
        |> Editable.value  --> "old"

    Editable.Editable "old" "new
        |> Editable.value  --> "new"

-}
value : Editable a -> a
value x =
    case x of
        Editable _ value ->
            value

        ReadOnly value ->
            value


{-| Determines if a modified value has changed from the saved one, by checking equality of both values.

If the `Editable` is `ReadOnly` then we return False.

    Editable.Editable "old" "old"
        |> Editable.isDirty  --> False

    Editable.Editable "old" "new"
        |> Editable.isDirty  --> True

-}
isDirty : Editable a -> Bool
isDirty x =
    isDirtyWith (==) x


{-| Determines if a modified value has changed from the saved one, by a provided function.

If the `Editable` is `ReadOnly` then we return False.

    Editable.Editable 1 2
        |> Editable.isDirtyWith (==)  --> False

    Editable.Editable "old" "new"
        |> Editable.isDirtyWith (==)  --> True

-}
isDirtyWith : (a -> a -> Bool) -> Editable a -> Bool
isDirtyWith f x =
    case x of
        ReadOnly _ ->
            False

        Editable saved modified ->
            f saved modified
