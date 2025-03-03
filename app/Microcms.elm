module Microcms exposing
    ( Post
    , Category
    , getPost
    , getPosts
    , getCategories
    , getPostsByCategory
    , envTask
    )

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Json.Decode as Decode exposing (Decoder)
import FatalError exposing (FatalError)
import BackendTask.Env
import Debug


-- 環境変数 "SERVICE_DOMAIN" と "API_KEY" を取得して Env レコードを作成
type alias Env =
    { serviceDomain : String
    , apiKey : String
    }


envTask : BackendTask FatalError Env
envTask =
    BackendTask.map2 Env
        (BackendTask.Env.expect "SERVICE_DOMAIN")
        (BackendTask.Env.expect "MICROCMS_API_KEY")
        |> BackendTask.allowFatal


microCmsURI : Env -> String
microCmsURI { serviceDomain } =
    "https://" ++ serviceDomain ++ "/api/v1"


type alias Post =
    { id : String
    , title : String
    , content : Maybe String
    , externalUrl : Maybe String
    , categories : List Category
    , publishedAt : String
    , slug : String
    }


type alias Category =
    { id : String
    , name : String
    , slug : String
    }

httpGet : Env -> String -> Decoder a -> BackendTask FatalError a
httpGet env path decoder =
    let
        url =
            microCmsURI env ++ path
    in
    Debug.log ("HTTP GET: " ++ url) url
        |> (\_ ->
                BackendTask.Http.getWithOptions
                    { url = url
                    , expect = BackendTask.Http.expectJson decoder
                    , headers = [ ( "X-MICROCMS-API-KEY", env.apiKey ) ]
                    , cacheStrategy = Just BackendTask.Http.IgnoreCache
                    , retries = Nothing
                    , timeoutInMs = Nothing
                    , cachePath = Nothing
                    }
           )
        |> BackendTask.allowFatal


getPosts : Env -> BackendTask FatalError (List Post)
getPosts env =
    httpGet env "/post?orders=-publishDate" postsDecoder


getPost : Env -> String -> BackendTask FatalError Post
getPost env slug =
    httpGet env ("/post?filters=slug[equals]" ++ slug)
        (Decode.field "contents" (Decode.index 0 postDecoder))


getCategories : Env -> BackendTask FatalError (List Category)
getCategories env =
    httpGet env "/categories" categoriesDecoder


getPostsByCategory : Env -> String -> BackendTask FatalError (List Post)
getPostsByCategory env categorySlug =
    -- First get all categories
    getCategories env
        |> BackendTask.andThen
            (\categories ->
                -- Find the category with matching slug
                case List.filter (\category -> category.slug == categorySlug) categories of
                    category :: _ ->
                        -- Use the category ID to filter posts
                        httpGet env ("/post?filters=categories[contains]" ++ category.id ++ "&orders=-publishDate") postsDecoder
                    
                    [] ->
                        -- If category not found, return empty list
                        BackendTask.succeed []
            )

postsDecoder : Decoder (List Post)
postsDecoder =
    Decode.field "contents" (Decode.list postDecoder)


postDecoder : Decoder Post
postDecoder =
    Decode.map7 Post
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "content" (Decode.nullable Decode.string))
        (Decode.oneOf
            [ Decode.field "externalUrl" (Decode.nullable Decode.string)
            , Decode.succeed Nothing
            ]
        )
        (Decode.field "categories" (Decode.list categoryDecoder))
        (Decode.field "publishedAt" Decode.string)
        (Decode.field "slug" Decode.string)


categoriesDecoder : Decoder (List Category)
categoriesDecoder =
    Decode.field "contents" (Decode.list categoryDecoder)


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.map3 Category
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "slug" Decode.string)
