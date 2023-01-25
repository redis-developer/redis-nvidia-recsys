import os.path as osp

from datetime import timedelta
from feast.types import Int32
from feast import Entity, Field, FeatureView, ValueType
from feast.infra.offline_stores.file_source import FileSource



dir_path = osp.dirname(osp.abspath(__file__))
data_path = osp.join(dir_path, "data")

user_features = FileSource(
    path=f"{data_path}/user_features.parquet",
    timestamp_field="datetime",
    created_timestamp_column="created",
)

user_raw = Entity(name="user_id_raw", value_type=ValueType.INT32, description="user id raw")

user_features_view = FeatureView(
    name="user_features",
    entities=[user_raw],
    ttl=timedelta(days=365),
    schema=[
        Field(name="user_shops", dtype=Int32),
        Field(name="user_profile", dtype=Int32),
        Field(name="user_group", dtype=Int32),
        Field(name="user_gender", dtype=Int32),
        Field(name="user_age", dtype=Int32),
        Field(name="user_consumption_2", dtype=Int32),
        Field(name="user_is_occupied", dtype=Int32),
        Field(name="user_geography", dtype=Int32),
        Field(name="user_intentions", dtype=Int32),
        Field(name="user_brands", dtype=Int32),
        Field(name="user_categories", dtype=Int32),
        Field(name="user_id", dtype=Int32),
    ],
    online=True,
    source=user_features
)