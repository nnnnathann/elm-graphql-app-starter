port module Main exposing (Flags, Model, Msg, main)

import Animator
import Animator.Css
import Api
import Browser
import Color exposing (Color)
import GraphQL.Engine as GQL
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode
import Json.Encode
import Queries.Hello.Hello as HelloQuery
import Time


type alias Flags =
    { dimensions : Dimensions }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { error : Maybe String
    , message : Maybe HelloQuery.Response
    , dimensions : Dimensions
    , animationState : Animator.Timeline AnimationState
    }


type AnimationState
    = Splash
    | WithMessage


init : Flags -> ( Model, Cmd Msg )
init { dimensions } =
    ( { error = Nothing
      , message = Nothing
      , dimensions = dimensions
      , animationState = Animator.init Splash
      }
    , runQuery GotHelloMessage HelloQuery.query
    )


type Msg
    = GotBackendMsg (Result String FromBackendMsg)
    | GotHelloMessage (Result GQL.Error HelloQuery.Response)
    | Tick Time.Posix


type FromBackendMsg
    = GotDimensions Dimensions


animator : Animator.Animator Model
animator =
    Animator.animator
        -- *NOTE*  We're using `the Animator.Css.watching` instead of `Animator.watching`.
        -- Instead of asking for a constant stream of animation frames, it'll only ask for one
        -- and we'll render the entire css animation in that frame.
        |> Animator.Css.watching .animationState
            (\newState model ->
                { model | animationState = newState }
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotHelloMessage res ->
            ( mapResponse (\val mod -> { mod | message = Just val, animationState = mod.animationState |> Animator.go Animator.verySlowly WithMessage }) res model
            , Cmd.none
            )

        GotBackendMsg res ->
            case res of
                Ok backendMsg ->
                    updateFromBackend backendMsg model

                Err err ->
                    ( { model | error = Just err }
                    , Cmd.none
                    )

        Tick newTime ->
            ( Animator.update newTime animator model
            , Cmd.none
            )


updateFromBackend : FromBackendMsg -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        GotDimensions dims ->
            ( { model | dimensions = dims }, Cmd.none )


port fromBackend : (Json.Encode.Value -> msg) -> Sub msg


type alias Dimensions =
    { width : Float
    , height : Float
    }


decodeDimensions : Json.Decode.Decoder Dimensions
decodeDimensions =
    Json.Decode.map2 Dimensions
        (Json.Decode.field "width" Json.Decode.float)
        (Json.Decode.field "height" Json.Decode.float)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ fromBackendSub
        , animator |> Animator.toSubscription Tick model
        ]


fromBackendSub : Sub Msg
fromBackendSub =
    let
        decodeBackendMsg : Json.Decode.Decoder FromBackendMsg
        decodeBackendMsg =
            Json.Decode.field "_tag" Json.Decode.string
                |> Json.Decode.andThen
                    (\tag ->
                        case tag of
                            "GotDimensions" ->
                                Json.Decode.field "dimensions" decodeDimensions
                                    |> Json.Decode.map GotDimensions

                            _ ->
                                Json.Decode.fail <| "unrecognized value from backend. I don't know how to handle the tag " ++ tag
                    )

        parseFromBackend : Json.Decode.Value -> Msg
        parseFromBackend value =
            Json.Decode.decodeValue decodeBackendMsg value
                |> Result.mapError Json.Decode.errorToString
                |> GotBackendMsg
    in
    fromBackend parseFromBackend


view : Model -> Html.Html Msg
view model =
    Animator.Css.div model.animationState
        [ Animator.Css.backgroundColor
            (\st ->
                case st of
                    Splash ->
                        Color.white

                    WithMessage ->
                        Color.blue
            )
        ]
        []
        [ viewApp model ]


isJust : Maybe a -> Bool
isJust m =
    case m of
        Just _ ->
            True

        Nothing ->
            False


viewApp : Model -> Html.Html Msg
viewApp model =
    case model.error of
        Just err ->
            Html.node "dialog" [ Attr.attribute "open" "" ] [ Html.text err ]

        Nothing ->
            case model.message of
                Nothing ->
                    viewLoader

                Just msg ->
                    Html.div [ Attr.class "appLayout p-4 rounded" ]
                        [ showMessage msg.message
                        ]


showMessage : HelloQuery.Message -> Html.Html msg
showMessage { text, requestedAt } =
    Html.div [] [ Html.text <| text ++ " " ++ showDate requestedAt ]


requestTimeoutMs : Maybe Float
requestTimeoutMs =
    Just 60000


mapResponse : (a -> Model -> Model) -> Result GQL.Error a -> Model -> Model
mapResponse f res model =
    case res of
        Ok a ->
            f a model

        Err err ->
            { model | error = Just (graphqlError err) }


graphqlError : GQL.Error -> String
graphqlError err =
    case err of
        GQL.BadBody { decodingError } ->
            "Incorrect body format: " ++ decodingError

        GQL.BadStatus { status } ->
            "I received an unexpected code (" ++ String.fromInt status ++ ") from the server. This may or may not be temporary. Please try again!"

        GQL.BadUrl msg ->
            "Configuration error: URL not valid (" ++ msg ++ ")"

        GQL.Timeout ->
            "This request took too long. Please wait a moment and try again"

        GQL.NetworkError ->
            "I'm having trouble contacting the server. Is your internet connection up and available?"


runQuery : (Result GQL.Error data -> Msg) -> Api.Query data -> Cmd Msg
runQuery toMsg query =
    Api.query query
        { headers = []
        , url = "/graphql"
        , timeout = requestTimeoutMs
        , tracker = Nothing
        }
        |> Cmd.map toMsg


showDate : Api.DateTime -> String
showDate (Api.DateTime dt) =
    dt


nonEmptyString : String -> Maybe String
nonEmptyString str =
    case str of
        "" ->
            Nothing

        nestr ->
            Just nestr


nonEmptyList : List a -> Maybe (List a)
nonEmptyList xs =
    case xs of
        [] ->
            Nothing

        _ ->
            Just xs


viewLoader : Html.Html msg
viewLoader =
    Html.div [] [ Html.text "loading" ]


appButton :
    { onClick : msg
    , label : String
    }
    -> Html.Html msg
appButton { onClick, label } =
    Html.button [ Events.onClick onClick, Attr.class "border px-2 py-1" ] [ Html.text label ]
