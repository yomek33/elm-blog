module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, text, small)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Microcms
import Server.Response
import ErrorPage
import HtmlParser
import Html.Attributes exposing (class)

-- MODEL & MESSAGE

type alias Model =
    {}

type alias Msg =
    ()


type alias RouteParams =
    { slug : String }

type alias Data =
    { post : Microcms.Post }

type alias ActionData =
    {}


fetchPost : RouteParams -> BackendTask FatalError Microcms.Post
fetchPost params =
    Microcms.envTask
        |> BackendTask.andThen (\env -> Microcms.getPost env params.slug)


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    fetchPost routeParams
        |> BackendTask.map (\post -> { post = post })



route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { head = head
        , data = \routeParams _ ->
            fetchPost routeParams
                |> BackendTask.map (\post -> { post = post })
                |> BackendTask.map Server.Response.render
        , action = \_ _ ->
            BackendTask.succeed (Server.Response.render {})
        }
        |> RouteBuilder.buildNoState { view = view }



head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "yomek33"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "yomek33 logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Yomek33"
        , locale = Nothing
        , title = app.data.post.title
        }
        |> Seo.website

view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = "yomek33"
    , body =
        [ div [class "article"]
            [ h1 [] [ text app.data.post.title ]
            , small  [] [text ( HtmlParser.trimDate app.data.post.publishedAt)
            , text (Maybe.withDefault "" (List.head app.data.post.categories |> Maybe.map (.name >> (++) "#")))]
            , case app.data.post.content of
                Just content ->
                   HtmlParser.parseHtml content
                Nothing ->
                    text ""
            ]
        ]
    }