import pickle

# Upload the file
with open('filtered_data.pkl', 'rb') as file:
    loaded_filtered_data = pickle.load(file)

# loaded_filtered_data is a dictionary with the following structure (includes header)
# {
#     ID: {
#         day: [consumption[0], consumption[1], ..., consumption[23]]
#     }
# }

# Additional statistics for the loaded filtered data
print('Number of unique users:', len(loaded_filtered_data))  # 5489
print('Number of rows:', sum([len(date_and_consumption) for date_and_consumption in loaded_filtered_data.values()]))  # 2772102
print('Number of users with more than 365 days of data:', sum([len(date_and_consumption) > 365 for date_and_consumption in loaded_filtered_data.values()]))  # 5118
print('Number of users with 365 days or fewer of data:', sum([len(date_and_consumption) <= 365 for date_and_consumption in loaded_filtered_data.values()]))  # 371