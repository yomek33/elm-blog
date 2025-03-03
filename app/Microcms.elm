module Microcms exposing (Post, Category, getPost, getPosts, getCategories, getPostsByCategory, envTask)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Json.Decode as Decode exposing (Decoder)
import FatalError exposing (FatalError)
import BackendTask.Env

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
    , categories : Category
    , publishedAt : String
    , slug : String
    }

type alias Category =
    { id : String
    , name : String
    , slug : String
    }


getPosts : Env -> BackendTask FatalError (List Post)
getPosts env =
    let
        url = microCmsURI env ++ "/post?orders=-publishDate"
        _ = Debug.log "getPosts URL" url
    in
    BackendTask.Http.getWithOptions
        { url = url
        , expect = BackendTask.Http.expectJson postsDecoder
        , headers = [ ( "X-MICROCMS-API-KEY", env.apiKey ) ]
        , cacheStrategy = Just BackendTask.Http.IgnoreCache
        , retries = Nothing
        , timeoutInMs = Nothing
        , cachePath = Nothing
        }
        |> BackendTask.map (\posts -> 
            let
                _ = Debug.log "getPosts result" posts
            in
            posts
        )
        |> BackendTask.allowFatal

getPost : Env -> String -> BackendTask FatalError Post
getPost env slug =
    let
        url = microCmsURI env ++ "/post?filters=slug[equals]" ++ slug
        _ = Debug.log "getPost URL" url
    in
    BackendTask.Http.getWithOptions
        { url = url
        , expect = BackendTask.Http.expectJson (Decode.field "contents" (Decode.index 0 postDecoder))
        , headers = [ ( "X-MICROCMS-API-KEY", env.apiKey ) ]
        , cacheStrategy = Just BackendTask.Http.IgnoreCache
        , retries = Nothing
        , timeoutInMs = Nothing
        , cachePath = Nothing
        }
        |> BackendTask.map (\post -> 
            let
                _ = Debug.log "getPost result" post
            in
            post
        )
        |> BackendTask.allowFatal

getCategories : Env -> BackendTask FatalError (List Category)
getCategories env =
    BackendTask.Http.getWithOptions
        { url = microCmsURI env ++ "/categories"
        , expect = BackendTask.Http.expectJson categoriesDecoder
        , headers = [ ( "X-MICROCMS-API-KEY", env.apiKey ) ]
        , cacheStrategy = Just BackendTask.Http.IgnoreCache
        , retries = Nothing
        , timeoutInMs = Nothing
        , cachePath = Nothing
        }
        |> BackendTask.allowFatal

getPostsByCategory : Env -> String -> BackendTask FatalError (List Post)
getPostsByCategory env categoryId =
    BackendTask.Http.getWithOptions
        { url = microCmsURI env ++ "/post?filters=categories[contains]" ++ categoryId ++ "&orders=-publishDate"
        , expect = BackendTask.Http.expectJson postsDecoder
        , headers = [ ( "X-MICROCMS-API-KEY", env.apiKey ) ]
        , cacheStrategy = Just BackendTask.Http.IgnoreCache
        , retries = Nothing
        , timeoutInMs = Nothing
        , cachePath = Nothing
        }
        |> BackendTask.allowFatal

postsDecoder : Decoder (List Post)
postsDecoder =
    Decode.field "contents" (Decode.list postDecoder)

postDecoder : Decoder Post
postDecoder =
    Decode.map7 Post
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "content" (Decode.nullable Decode.string))
        (Decode.field "externalUrl" (Decode.nullable Decode.string))
        (Decode.field "category" categoryDecoder)
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
