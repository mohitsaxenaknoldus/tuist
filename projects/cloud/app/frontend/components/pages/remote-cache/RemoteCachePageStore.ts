import { CreateS3BucketDocument } from '../../../graphql/types';
import { ApolloClient } from '@apollo/client';
import { SelectOption } from '@shopify/polaris';
import { makeAutoObservable } from 'mobx';
import ProjectStore from '../../../stores/ProjectStore';

class RemoteCachePageStore {
  bucketName = '';
  accessKeyId = '';
  secretAccessKey = '';
  bucketOptions: SelectOption[] = [
    {
      label: 'Create new bucket',
      value: 'new',
    },
  ];
  selectedOption = 'new';

  client: ApolloClient<object>;
  projectStore: ProjectStore;

  constructor(
    client: ApolloClient<object>,
    projectStore: ProjectStore,
  ) {
    this.client = client;
    this.projectStore = projectStore;
    makeAutoObservable(this);
  }

  get isApplyChangesButtonDisabled() {
    return (
      this.bucketName.length === 0 ||
      this.accessKeyId.length === 0 ||
      this.secretAccessKey.length === 0
    );
  }

  get isCreatingBucket() {
    return true;
  }

  async applyChangesButtonClicked(accountId: string) {
    if (this.isCreatingBucket) {
      const { data } = await this.client.mutate({
        mutation: CreateS3BucketDocument,
        variables: {
          input: {
            name: this.bucketName,
            accessKeyId: this.accessKeyId,
            secretAccessKey: this.secretAccessKey,
            accountId,
          },
        },
      });
      this.projectStore.project?.remoteCacheStorage =
    }
  }
}

export default RemoteCachePageStore;
