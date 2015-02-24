from pycrawlers.examples.youtube import crawlers
import pandas as pd 
from pymongo import MongoClient
import os

YT_CHANNEL_ID = os.environ.get("YT_CHANNEL_ID", "TWuseRGroup")
MONGO_URI = os.environ.get("MONGO_URI","mongodb://localhost:27017/agilearning")
DB_NAME = os.environ.get("DB_NAME","agilearning")
LEARNING_RESOURCE_COLLECTION_NAME = os.environ.get("LEARNING_RESOURCE_COLLECTION_NAME","learningResources")


mongo_cli = MongoClient(MONGO_URI)
learning_resources_collection = mongo_cli[DB_NAME][LEARNING_RESOURCE_COLLECTION_NAME]

video_data = crawlers.crawl_channel_uploads(YT_CHANNEL_ID)
video_data_df = pd.DataFrame(video_data)

video_data_df = video_data_df[["title","description","ytid"]]
video_data_df.columns = [u'ytTitle', u'ytDescription', u'ytid']
video_data_df["youtubeVideoId"] = video_data_df["ytid"]
video_data_df = video_data_df.drop("ytid",1)
video_data_df["_id"] = video_data_df["youtubeVideoId"].map(lambda xx:"YTV_"+xx)
video_data_df["type"] = "youtube"

learning_resources_collection.insert(video_data_df.to_dict(orient="records"))


