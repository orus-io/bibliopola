module Update exposing (init, onUrlChange, onUrlRequest, update)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Model.Book as Book
import Model.Shelf as Shelf
import Route exposing (..)
import SelectList
import Types exposing (..)
import Url exposing (Url)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            Tuple.pair model Cmd.none

        ClickLink (Internal url) ->
            Tuple.pair model
                -- TODO replaceも使う
                (Nav.pushUrl model.key <| Url.toString url)

        ClickLink (External url) ->
            Tuple.pair model <| Nav.load url

        ChangeRoute route ->
            Tuple.pair
                { model | shelf = Shelf.attempt (Shelf.findPage route) model.shelf }
                Cmd.none

        RouteError ->
            Tuple.pair model Cmd.none

        LogMsg message ->
            let
                log =
                    case model.logs of
                        latest :: _ ->
                            { message = message, id = latest.id + 1 }

                        [] ->
                            { message = message, id = 0 }
            in
            Tuple.pair { model | logs = log :: model.logs } Cmd.none

        ClearLogs ->
            Tuple.pair { model | logs = [] } Cmd.none

        SetShelf shelf ->
            Tuple.pair { model | shelf = shelf } Cmd.none

        SetPanel panel ->
            Tuple.pair { model | panel = panel } Cmd.none


init : Shelf -> () -> Url -> Key -> ( Model, Cmd Msg )
init shelf _ url key =
    update (onUrlChange url)
        { shelf = shelf
        , panel =
            SelectList.fromLists []
                StoryPanel
                [ MsgLoggerPanel, CreditPanel ]
        , logs = []
        , key = key
        }


onUrlRequest : UrlRequest -> Msg
onUrlRequest request =
    ClickLink request


onUrlChange : Url -> Msg
onUrlChange url =
    Route.parse url
        |> Maybe.map ChangeRoute
        |> Maybe.withDefault RouteError
