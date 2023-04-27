module Queries.Hello.Hello exposing (Message, Response, query)

{-| 
This file is generated from src/Queries/Hello.gql using `elm-gql`

Please avoid modifying directly.


@docs Response

@docs query

@docs Message


-}


import Api
import GraphQL.Engine
import Json.Decode


query : Api.Query Response
query =
    GraphQL.Engine.bakeToSelection
        (Just "Hello")
        (\version_ ->
            { args = []
            , body = toPayload_ version_
            , fragments = toFragments_ version_
            }
        )
        decoder_


{-  Return data  -}


type alias Response =
    { message : Message }


type alias Message =
    { text : String, requestedAt : Api.DateTime }


decoder_ : Int -> Json.Decode.Decoder Response
decoder_ version_ =
    Json.Decode.succeed Response
        |> GraphQL.Engine.versionedJsonField
            version_
            "message"
            (Json.Decode.succeed Message
                |> GraphQL.Engine.versionedJsonField 0 "text" Json.Decode.string
                |> GraphQL.Engine.versionedJsonField
                    0
                    "requestedAt"
                    Api.dateTime.decoder
            )


toPayload_ : Int -> String
toPayload_ version_ =
    GraphQL.Engine.versionedAlias version_ "message"
        ++ """ {text
requestedAt }"""


toFragments_ : Int -> String
toFragments_ version_ =
    String.join """
""" []


